import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ "currentTheme", "preferedTheme", "themeButton" ]

  connect() {
    this.set_theme(localStorage.getItem("theme") || "auto")
  }

  preferedThemeTargetConnected(element) {
    element.hidden = element.dataset.theme != this.prefered_theme()
  }

  setCurrentTheme(event) {
    let new_theme = event.params.theme

    this.set_theme(new_theme)
    localStorage.setItem('theme', new_theme)
  }

  prefered_theme() {
    // document.querySelector("html").getAttribute("data-bs-theme")
    return window.matchMedia("(prefers-color-scheme: dark)").matches ? "dark" : "light"
  }

  set_theme(theme) {
    this.set_active(theme)

    if (theme == "auto") {
      theme = this.prefered_theme()
    }
    document.querySelector("html").setAttribute("data-bs-theme", theme)

    this.currentThemeTargets.forEach(element => {
      element.hidden = element.dataset.theme != theme
    })
  }

  set_active(theme) {
    this.themeButtonTargets.forEach(element => {
      if (element.dataset.theme == theme) {
        element.classList.add("active")
      } else {
        element.classList.remove("active")
      }
    })
  }
}
