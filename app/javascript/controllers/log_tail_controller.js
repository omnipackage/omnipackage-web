import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ "log", "toggleAutoscrollInput"]

  connect() {
    let observer = new MutationObserver((mutationsList, observer) => {
      if (this.toggleAutoscrollInputTarget.checked) {
        this.scrollToBottom()
      }
    });
    observer.observe(this.logTarget, {characterData: false, childList: true, attributes: false});
  }

  scrollToBottom() {
    this.logTarget.scrollIntoView({ behavior: 'smooth', block: 'end' })
  }
}
