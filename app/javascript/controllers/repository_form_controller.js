import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ "collapseblock", "enablecheckbox" ]

  connect() {
    this.setCollapse()
  }

  setCollapse() {
    if (this.enablecheckboxTarget.checked) {
      this.show()
    } else {
      this.hide()
    }
  }

  show() {
    this.collapseblockTarget.classList.add("show")
    this.collapseblockTarget.setAttribute("aria-expanded", "true");
  }

  hide() {
    this.collapseblockTarget.classList.remove("show")
    this.collapseblockTarget.setAttribute("aria-expanded", "false");
  }
}
