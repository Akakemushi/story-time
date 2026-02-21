import { Controller } from "@hotwired/stimulus"

// Parallax background that responds to mouse movement.
// Layer speed is set via data-parallax-speed (0 = static, 1 = max movement).
// Max displacement for the fastest layer: 100px horizontal, 50px vertical.
export default class extends Controller {
  static targets = ["scene", "layer"]

  connect() {
    this.maxX = 80   // px — max horizontal shift for speed=1 layer
    this.maxY = 40   // px — max vertical shift for speed=1 layer

    // Current interpolated position (for smooth lerp)
    this.currentX = 0
    this.currentY = 0
    // Target position from mouse
    this.targetX = 0
    this.targetY = 0

    this.animationId = null
    this.handleMouseMove = this._onMouseMove.bind(this)
    this.handleMouseLeave = this._onMouseLeave.bind(this)

    this.element.addEventListener("mousemove", this.handleMouseMove)
    this.element.addEventListener("mouseleave", this.handleMouseLeave)

    // Start the animation loop
    this._animate()
  }

  disconnect() {
    this.element.removeEventListener("mousemove", this.handleMouseMove)
    this.element.removeEventListener("mouseleave", this.handleMouseLeave)
    if (this.animationId) {
      cancelAnimationFrame(this.animationId)
    }
  }

  _onMouseMove(event) {
    const rect = this.element.getBoundingClientRect()
    // Normalize mouse position to -1...1 range (0,0 = center)
    const x = ((event.clientX - rect.left) / rect.width - 0.5) * 2
    const y = ((event.clientY - rect.top) / rect.height - 0.5) * 2

    this.targetX = x
    this.targetY = y
  }

  _onMouseLeave() {
    // Drift back to center when mouse leaves
    this.targetX = 0
    this.targetY = 0
  }

  _animate() {
    // Lerp toward target for smooth movement
    const ease = 0.06
    this.currentX += (this.targetX - this.currentX) * ease
    this.currentY += (this.targetY - this.currentY) * ease

    this.layerTargets.forEach((layer) => {
      const speed = parseFloat(layer.dataset.parallaxSpeed) || 0
      if (speed === 0) return // Layer 1 stays put

      const offsetX = this.currentX * this.maxX * speed
      const offsetY = this.currentY * this.maxY * speed

      layer.style.transform = `translate(${offsetX}px, ${offsetY}px)`
    })

    this.animationId = requestAnimationFrame(() => this._animate())
  }
}
