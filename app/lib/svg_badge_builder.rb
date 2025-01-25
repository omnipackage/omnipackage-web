class SvgBadgeBuilder # rubocop: disable Metrics/ClassLength
  attr_reader :title, :text

  def initialize(title:, text:)
    @title = title
    @text = text.truncate(13, omission: '')
  end

  def save(dir:, filename:)
    ::File.open(::Pathname.new(dir).join(filename), 'wb') do |file|
      file.write(generate)
    end
  end

  def generate # rubocop: disable Metrics/MethodLength
    <<~SVG.squish
    <?xml version="1.0" encoding="UTF-8" standalone="no"?>
    <svg
       width="108"
       height="20"
       role="img"
       aria-label="#{title}"
       version="1.1"
       id="svg8"
       sodipodi:docname="badge.svg"
       inkscape:version="1.3.2 (091e20ef0f, 2023-11-25)"
       xmlns:inkscape="http://www.inkscape.org/namespaces/inkscape"
       xmlns:sodipodi="http://sodipodi.sourceforge.net/DTD/sodipodi-0.dtd"
       xmlns="http://www.w3.org/2000/svg"
       xmlns:svg="http://www.w3.org/2000/svg"
       xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
       xmlns:cc="http://creativecommons.org/ns#"
       xmlns:dc="http://purl.org/dc/elements/1.1/">
      <defs
         id="defs8">
        <filter
           id="colors463654806"
           x="-0.027472527"
           y="-0.027455101"
           width="1.0549451"
           height="1.0549204">
          <feColorMatrix
             type="matrix"
             values="0 0 0 0 0.21875  0 0 0 0 0.4609375  0 0 0 0 0.11328125  0 0 0 1 0"
             class="icon-feColorMatrix "
             id="feColorMatrix27" />
        </filter>
        <linearGradient
           id="92"
           x1="0"
           y1="0"
           x2="1"
           y2="0">
          <stop
             offset="0%"
             stop-color="#fa71cd"
             id="stop1-8" />
          <stop
             offset="100%"
             stop-color="#9b59b6"
             id="stop2-4" />
        </linearGradient>
        <linearGradient
           id="93"
           x1="0"
           y1="0"
           x2="1"
           y2="0">
          <stop
             offset="0%"
             stop-color="#f9d423"
             id="stop3" />
          <stop
             offset="100%"
             stop-color="#f83600"
             id="stop4" />
        </linearGradient>
        <linearGradient
           id="94"
           x1="0"
           y1="0"
           x2="1"
           y2="0">
          <stop
             offset="0%"
             stop-color="#0064d2"
             id="stop5" />
          <stop
             offset="100%"
             stop-color="#1cb0f6"
             id="stop6" />
        </linearGradient>
        <linearGradient
           id="95"
           x1="0"
           y1="0"
           x2="1"
           y2="0">
          <stop
             offset="0%"
             stop-color="#f00978"
             id="stop7" />
          <stop
             offset="100%"
             stop-color="#3f51b1"
             id="stop8" />
        </linearGradient>
        <linearGradient
           id="96"
           x1="0"
           y1="0"
           x2="1"
           y2="0">
          <stop
             offset="0%"
             stop-color="#7873f5"
             id="stop9" />
          <stop
             offset="100%"
             stop-color="#ec77ab"
             id="stop10" />
        </linearGradient>
        <linearGradient
           id="97"
           x1="0"
           y1="0"
           x2="1"
           y2="0">
          <stop
             offset="0%"
             stop-color="#f9d423"
             id="stop11" />
          <stop
             offset="100%"
             stop-color="#e14fad"
             id="stop12" />
        </linearGradient>
        <linearGradient
           id="98"
           x1="0"
           y1="0"
           x2="1"
           y2="0">
          <stop
             offset="0%"
             stop-color="#009efd"
             id="stop13" />
          <stop
             offset="100%"
             stop-color="#2af598"
             id="stop14" />
        </linearGradient>
        <linearGradient
           id="99"
           x1="0"
           y1="0"
           x2="1"
           y2="0">
          <stop
             offset="0%"
             stop-color="#ffcc00"
             id="stop15" />
          <stop
             offset="100%"
             stop-color="#00b140"
             id="stop16" />
        </linearGradient>
        <linearGradient
           id="100"
           x1="0"
           y1="0"
           x2="1"
           y2="0">
          <stop
             offset="0%"
             stop-color="#d51007"
             id="stop17" />
          <stop
             offset="100%"
             stop-color="#ff8177"
             id="stop18" />
        </linearGradient>
        <linearGradient
           id="102"
           x1="0"
           y1="0"
           x2="1"
           y2="0">
          <stop
             offset="0%"
             stop-color="#a2b6df"
             id="stop19" />
          <stop
             offset="100%"
             stop-color="#0c3483"
             id="stop20" />
        </linearGradient>
        <linearGradient
           id="103"
           x1="0"
           y1="0"
           x2="1"
           y2="0">
          <stop
             offset="0%"
             stop-color="#7ac5d8"
             id="stop21" />
          <stop
             offset="100%"
             stop-color="#eea2a2"
             id="stop22" />
        </linearGradient>
        <linearGradient
           id="104"
           x1="0"
           y1="0"
           x2="1"
           y2="0">
          <stop
             offset="0%"
             stop-color="#00ecbc"
             id="stop23" />
          <stop
             offset="100%"
             stop-color="#007adf"
             id="stop24" />
        </linearGradient>
        <linearGradient
           id="105"
           x1="0"
           y1="0"
           x2="1"
           y2="0">
          <stop
             offset="0%"
             stop-color="#b88746"
             id="stop25" />
          <stop
             offset="100%"
             stop-color="#fdf5a6"
             id="stop26" />
        </linearGradient>
        <filter
           id="filter1"
           x="-0.027472528"
           y="-0.027455101"
           width="1.0549451"
           height="1.0549204">
          <feColorMatrix
             type="matrix"
             values="0 0 0 0 0.21875  0 0 0 0 0.4609375  0 0 0 0 0.11328125  0 0 0 1 0"
             class="icon-feColorMatrix "
             id="feColorMatrix1" />
        </filter>
        <filter
           id="colorsf2281628112">
          <feColorMatrix
             type="matrix"
             values="0 0 0 0 0.99609375  0 0 0 0 0.99609375  0 0 0 0 0.99609375  0 0 0 1 0"
             class="icon-fecolormatrix"
             id="feColorMatrix28" />
        </filter>
        <filter
           id="colorsb235973158">
          <feColorMatrix
             type="matrix"
             values="0 0 0 0 0  0 0 0 0 0  0 0 0 0 0  0 0 0 1 0"
             class="icon-fecolormatrix"
             id="feColorMatrix29" />
        </filter>
        <filter
           id="colors8713597652"
           x="-0.027472527"
           y="-0.027455101"
           width="1.0549451"
           height="1.0549204">
          <feColorMatrix
             type="matrix"
             values="0 0 0 0 0.21875  0 0 0 0 0.4609375  0 0 0 0 0.11328125  0 0 0 1 0"
             class="icon-feColorMatrix "
             id="feColorMatrix27-5" />
        </filter>
        <filter
           id="filter1-1"
           x="-0.027472528"
           y="-0.027455101"
           width="1.0549451"
           height="1.0549204">
          <feColorMatrix
             type="matrix"
             values="0 0 0 0 0.21875  0 0 0 0 0.4609375  0 0 0 0 0.11328125  0 0 0 1 0"
             class="icon-feColorMatrix "
             id="feColorMatrix1-9" />
        </filter>
        <filter
           id="colorsf2558080456">
          <feColorMatrix
             type="matrix"
             values="0 0 0 0 0.99609375  0 0 0 0 0.99609375  0 0 0 0 0.99609375  0 0 0 1 0"
             class="icon-fecolormatrix"
             id="feColorMatrix28-5" />
        </filter>
        <filter
           id="colorsb8845622602">
          <feColorMatrix
             type="matrix"
             values="0 0 0 0 0  0 0 0 0 0  0 0 0 0 0  0 0 0 1 0"
             class="icon-fecolormatrix"
             id="feColorMatrix29-7" />
        </filter>
      </defs>
      <sodipodi:namedview
         id="namedview8"
         pagecolor="#505050"
         bordercolor="#ffffff"
         borderopacity="1"
         inkscape:showpageshadow="0"
         inkscape:pageopacity="0"
         inkscape:pagecheckerboard="1"
         inkscape:deskcolor="#d1d1d1"
         inkscape:zoom="7.9999999"
         inkscape:cx="54.812501"
         inkscape:cy="20.5625"
         inkscape:window-width="1920"
         inkscape:window-height="1016"
         inkscape:window-x="0"
         inkscape:window-y="0"
         inkscape:window-maximized="1"
         inkscape:current-layer="g5" />
      <title
         id="title1">#{title}</title>
      <linearGradient
         id="s"
         x2="0"
         y2="100%">
        <stop
           offset="0"
           stop-color="#bbb"
           stop-opacity=".1"
           id="stop1" />
        <stop
           offset="1"
           stop-opacity=".1"
           id="stop2" />
      </linearGradient>
      <clipPath
         id="r">
        <rect
           width="108"
           height="20"
           rx="3"
           fill="#fff"
           id="rect2" />
      </clipPath>
      <g
         clip-path="url(#r)"
         id="g5">
        <rect
           width="17.38188"
           height="20"
           fill="#555555"
           id="rect3"
           x="0"
           y="0"
           style="stroke-width:0.635791" />
        <rect
           x="17.290197"
           width="90.709808"
           height="19.99646"
           fill="#44cc11"
           id="rect4"
           y="0.0035400391"
           style="stroke-width:1.013" />
        <rect
           width="108"
           height="20"
           fill="url(#s)"
           id="rect5" />
        <text
           xml:space="preserve"
           style="font-style:normal;font-variant:normal;font-weight:500;font-stretch:normal;font-size:12px;line-height:1.45;font-family:Roboto;-inkscape-font-specification:'Roboto Medium';fill:#4d4d4d;fill-opacity:1"
           x="19.094727"
           y="14.314941"
           id="text1"><tspan
             sodipodi:role="line"
             id="tspan1"
             x="19.094727"
             y="14.314941">#{text}</tspan></text>
      </g>
      <g
         fill="#fff"
         text-anchor="middle"
         font-family="Verdana,Geneva,DejaVu Sans,sans-serif"
         text-rendering="geometricPrecision"
         font-size="110"
         id="g8" />
      <path
         style="fill:#3db70f;fill-opacity:1;stroke-width:0.03125"
         d="m 7.0724346,16.559814 c -0.902344,-0.521216 -2.224219,-1.284749 -2.9375,-1.696741 -0.713281,-0.411992 -1.482661,-0.853682 -1.709734,-0.981533 l -0.412858,-0.232457 0.0066,-3.902221 0.0066,-3.9022206 3.328125,-1.9225626 c 1.830469,-1.0574094 3.349219,-1.9240663 3.375,-1.9259042 0.02578,-0.00184 1.5550774,0.8665429 3.3984324,1.929735 l 3.35157,1.9330765 -2.4e-4,3.8794239 -2.3e-4,3.879423 -0.64821,0.373057 c -0.35651,0.205181 -0.81695,0.473788 -1.0232,0.596905 -0.69648,0.415752 -5.0451114,2.920667 -5.0695304,2.920173 -0.01332,-2.69e-4 -0.762498,-0.426939 -1.664842,-0.948154 z m 3.0937494,-0.65334 1.421876,-0.820433 0.008,-1.645697 0.008,-1.645698 -1.4291,-0.816819 C 8.9764746,10.292817 8.7356366,10.165998 8.6824986,10.19193 c -0.03485,0.01701 -0.675083,0.381493 -1.422739,0.809968 l -1.359375,0.779044 -0.0081,1.655832 -0.0081,1.655831 0.773709,0.442675 c 0.42554,0.243472 1.06199,0.610005 1.414334,0.814519 0.352344,0.204513 0.647656,0.373028 0.65625,0.374476 0.0086,0.0014 0.6554689,-0.366562 1.4374994,-0.817801 z m -3.1887174,-5.513325 1.764407,-1.0080829 0.09497,0.055518 c 0.05223,0.030535 0.8437959,0.4831569 1.7590294,1.0058269 l 1.664067,0.950311 v 1.633993 c 0,0.961637 0.0117,1.633993 0.0285,1.633993 0.0157,0 0.20901,-0.103796 0.42968,-0.230657 l 0.40123,-0.230657 0.008,-2.543734 0.008,-2.5437331 L 11.08225,7.92938 C 9.9529865,7.2767789 8.9640056,6.705308 8.8844576,6.6594446 l -0.144633,-0.083389 -2.200883,1.2719181 -2.200882,1.2719181 -0.008,2.5355172 -0.008,2.535517 0.42987,0.249367 0.429871,0.249367 0.01563,-1.644214 0.01563,-1.644215 z m -3.303653,0.863423 0.008,-2.5331368 2.515621,-1.4536556 c 1.383594,-0.7995104 2.522774,-1.4560835 2.531511,-1.459051 0.0087,-0.00297 1.1582649,0.6543391 2.5545044,1.4606816 l 2.53862,1.4660772 0.008,2.5239986 0.008,2.523998 0.47623,-0.271325 0.47623,-0.271326 3.3e-4,-3.502874 3.3e-4,-3.5028744 -2.97316,-1.7158759 C 10.182782,3.5774771 8.8194906,2.7929811 8.7884846,2.7778843 c -0.04409,-0.021466 -0.691883,0.3390114 -2.97215,1.6539078 -1.603676,0.9247462 -2.968509,1.7142275 -3.032963,1.7544031 l -0.117187,0.073047 V 9.739399 c 0,3.197252 0.0042,3.483643 0.05161,3.523045 0.06591,0.05477 0.893802,0.526512 0.924768,0.526941 0.01279,1.78e-4 0.02685,-1.139588 0.031251,-2.532813 z"
         id="path314" />
      <path
         style="fill:#5a5a5a;fill-opacity:1;stroke-width:0.0441942"
         d=""
         id="path322" />
      <metadata
         id="metadata328">
        <rdf:RDF>
          <cc:Work
             rdf:about="">
            <dc:title>#{title}</dc:title>
          </cc:Work>
        </rdf:RDF>
      </metadata>
    </svg>
    SVG
  end
end
