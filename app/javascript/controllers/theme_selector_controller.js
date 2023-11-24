import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ "currentThemeDark", "currentThemeLight" ]

  connect() {
    let theme = this.getCookie("theme")
    if (theme && theme != "auto") {
      this.set_theme(theme)
    } else {
      this.set_theme(this.prefered_theme())
    }
  }

  light() {
    this.set_theme("light")
    this.save_theme("light")
  }

  dark() {
    this.set_theme("dark")
    this.save_theme("dark")
  }

  auto() {
    this.set_theme(this.prefered_theme())
    this.save_theme("auto")
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
