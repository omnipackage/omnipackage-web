import { Controller } from "@hotwired/stimulus"
import cookies from "lib/cookies"

export default class extends Controller {
  static targets = [ "currentTheme", "preferedTheme", "themeButton" ]

  connect() {
    let theme = cookies.get("theme")
    if (theme && theme != "auto") {
      this.set_theme(theme)
      this.set_active(theme)
    } else {
      this.set_theme(this.prefered_theme())
      this.set_active("auto")
    }

    this.preferedThemeTargets.forEach((element, index) => {
      element.hidden = element.dataset.theme != this.prefered_theme()
    })
  }

  switch(event) {
    let new_theme = event.target.dataset.theme

    this.set_theme(new_theme == "auto" ? this.prefered_theme() : new_theme)
    this.set_active(new_theme)
    cookies.set("theme", new_theme, 12345)
  }

  prefered_theme() {
    // document.querySelector("html").getAttribute("data-bs-theme")
    return window.matchMedia("(prefers-color-scheme: dark)").matches ? "dark" : "light"
  }

  set_theme(theme) {
    document.querySelector("html").setAttribute("data-bs-theme", theme)

    this.currentThemeTargets.forEach((element, index) => {
      element.hidden = element.dataset.theme != theme
    })
  }

  set_active(theme) {
    this.themeButtonTargets.forEach((element, index) => {
      if (element.dataset.theme == theme) {
        element.classList.add("active")
      } else {
        element.classList.remove("active")
      }
    })
  }
}
