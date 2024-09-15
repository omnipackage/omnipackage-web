import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ "log" ]

  connect() {

  }

  scrollToBottom(event) {
    event.preventDefault()
    this.logTarget.scrollIntoView({ behavior: 'smooth', block: 'end' })
  }
}
