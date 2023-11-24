import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ "currentThemeDark", "currentThemeLight", "activeThemeLight", "activeThemeDark", "activeThemeAuto" ]

  connect() {
    let theme = this.getCookie("theme")
    if (theme && theme != "auto") {
      this.set_theme(theme)
      this.set_active(theme)
    } else {
      this.set_theme(this.prefered_theme())
      this.set_active("auto")
    }
  }

  light() {
    this.set_theme("light")
    this.save_theme("light")
    this.set_active("light")
  }

  dark() {
    this.set_theme("dark")
    this.save_theme("dark")
    this.set_active("dark")
  }

  auto() {
    this.set_theme(this.prefered_theme())
    this.save_theme("auto")
    this.set_active("auto")
  }

  //current_theme() {
  //  return document.querySelector("html").getAttribute("data-bs-theme")
  //}

  prefered_theme() {
    return window.matchMedia("(prefers-color-scheme: dark)").matches ? "dark" : "light"
  }

  set_theme(theme) {
    document.querySelector("html").setAttribute("data-bs-theme", theme)

    if (theme == "light") {
      this.currentThemeDarkTargets.forEach((element, index) => {
        element.hidden = true
      })
      this.currentThemeLightTargets.forEach((element, index) => {
        element.hidden = false
      })
    } else {
      this.currentThemeLightTargets.forEach((element, index) => {
        element.hidden = true
      })
      this.currentThemeDarkTargets.forEach((element, index) => {
        element.hidden = false
      })
    }
  }

  set_active(theme) {
    switch(theme) {
      case "dark":
        this.activeThemeLightTargets.forEach((element, index) => {
          this.remove_active_class(element)
        })
        this.activeThemeDarkTargets.forEach((element, index) => {
          this.add_active_class(element)
        })
        this.activeThemeAutoTargets.forEach((element, index) => {
          this.remove_active_class(element)
        })
        break;
      case "light":
        this.activeThemeLightTargets.forEach((element, index) => {
          this.add_active_class(element)
        })
        this.activeThemeDarkTargets.forEach((element, index) => {
          this.remove_active_class(element)
        })
        this.activeThemeAutoTargets.forEach((element, index) => {
          this.remove_active_class(element)
        })
        break;
      case "auto":
        this.activeThemeLightTargets.forEach((element, index) => {
          this.remove_active_class(element)
        })
        this.activeThemeDarkTargets.forEach((element, index) => {
          this.remove_active_class(element)
        })
        this.activeThemeAutoTargets.forEach((element, index) => {
          this.add_active_class(element)
        })
        break;
    }
  }

  add_active_class(element) {
    if (element.classList.contains("active")) {
      return
    }
    element.classList.add("active")
  }

  remove_active_class(element) {
    element.classList.remove("active")
  }

  save_theme(theme) {
    this.setCookie("theme", theme, 12345)
  }

  setCookie(cname, cvalue, exdays) {
    const d = new Date();
    d.setTime(d.getTime() + (exdays * 24 * 60 * 60 * 1000));
    let expires = "expires="+d.toUTCString();
    document.cookie = cname + "=" + cvalue + ";" + expires + ";path=/";
  }

  getCookie(cname) {
    let name = cname + "=";
    let ca = document.cookie.split(';');
    for(let i = 0; i < ca.length; i++) {
      let c = ca[i];
      while (c.charAt(0) == ' ') {
        c = c.substring(1);
      }
      if (c.indexOf(name) == 0) {
        return c.substring(name.length, c.length);
      }
    }
    return "";
  }
}
