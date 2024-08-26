import { Controller } from "@hotwired/stimulus"
import slugify from "slugify"

export default class extends Controller {
  static targets = [ "name", "slug", "exampleUrl" ]

  connect() {
    this._updateSlug()
  }

  onNameChange(event) {
    event.preventDefault()
    if (!this._slugChangedByUser) {
      this._updateSlug()
    }
  }

  onSlugChange(event) {
    event.preventDefault()
    this._updateExampleUrl()
    this._slugChangedByUser = true;
  }

  _updateSlug() {
    let slug = slugify(this.nameTarget.value, { lower: true, strict: true });
    this.slugTarget.value = slug
    this._updateExampleUrl()
  }

  _updateExampleUrl() {
    this.exampleUrlTarget.innerHTML = `${window.js_variables.storage_base_url}-${this.slugTarget.value}`
  }
}
