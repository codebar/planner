def without_bullet
  Bullet.raise = false if Bullet.enable?
  Bullet.profile { yield }
  Bullet.raise = true if Bullet.enable?
end
