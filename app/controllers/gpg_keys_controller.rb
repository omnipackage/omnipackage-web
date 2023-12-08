# frozen_string_literal: true

class GpgKeysController < ::ApplicationController
  def index
    @current_key = current_key

    respond_to do |format|
      format.html do # rubocop: disable Lint/EmptyBlock
      end

      format.gzip do
        set_nocache
        oname = @key_source.class.name.underscore.split('/').last
        send_data(keys_export_gzip(@current_key), filename: "gpg_keys_#{oname}_#{@key_source.id}.tar.gz")
      end
    end
  end

  def generate
    gpg = ::Gpg.new.generate_keys(current_user.displayed_name, current_user.email)
    key_source.gpg_key_private = gpg.priv
    key_source.gpg_key_public = gpg.pub
    key_source.save!
    redirect_to(gpg_index_polymorphic_path, notice: 'New GPG key has been successfully generated')
  end

  def upload # rubocop: disable Metrics/AbcSize, Metrics/MethodLength
    key = ::Gpg::Key[params.fetch(:private_key), params.fetch(:public_key)]
    key_error = validate_key(key)

    respond_to do |format|
      if key_error || !key_source.update(gpg_key_private: key.priv, gpg_key_public: key.pub)
        format.turbo_stream do
          render(turbo_stream: turbo_stream.update('gpg_keys_upload_error', partial: 'gpg_keys/upload_error', locals: { error: key_error || key_source.errors.full_messages.to_sentence }))
        end
        format.html do
          redirect_to(gpg_index_polymorphic_path, alert: 'Error uploading keys')
        end
      else
        format.html do
          redirect_to(gpg_index_polymorphic_path, notice: 'New GPG key has been successfully uploaded')
        end
      end
    end
  end

  def destroy
    if key_source.is_a?(::User)
      redirect_to(gpg_index_polymorphic_path, alert: 'Cannot delete account key')
    else
      key_source.update!(gpg_key_private: nil, gpg_key_public: nil)
      redirect_to(gpg_index_polymorphic_path, notice: 'The key has been succesfully deleted')
    end
  end

  private

  %i[generate upload index destroy].each do |met|
    define_method("gpg_#{met}_polymorphic_path") do
      case key_source
      when ::Repository
        send("repository_#{met}_gpg_key_path", key_source.id)
      else
        send("#{met}_gpg_key_path")
      end
    end
    helper_method "gpg_#{met}_polymorphic_path"
  end

  def key_source
    @key_source ||= if params[:repository_id]
                      current_user.repositories.find(params[:repository_id])
                    else
                      current_user
                    end
  end

  def current_key
    case key_source
    when ::Repository
      if key_source.with_own_gpg_key?
        key_source.gpg_key
      end
    else
      key_source.gpg_key
    end
  end

  def validate_key(key)
    ::Gpg.new.test_key(key)
  rescue ::StandardError => e
    e.message
  end

  def keys_export_gzip(key)
    dir = ::Dir.mktmpdir
    { 'private.key' => key.priv, 'public.key' => key.pub }.each do |fname, k|
      ::File.open(::Pathname.new(dir).join(fname), 'w') do |file|
        file.write(k)
      end
    end
    ::ShellUtil.execute('tar', '-cz', '-', '.', chdir: dir).out
  ensure
    ::FileUtils.remove_entry_secure(dir)
  end
end
