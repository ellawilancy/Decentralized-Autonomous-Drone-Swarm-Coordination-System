;; Drone Registry Contract

;; Constants
(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-not-found (err u101))
(define-constant err-already-registered (err u102))

;; Data Variables
(define-data-var last-drone-id uint u0)

;; Data Maps
(define-map drones
  { drone-id: uint }
  {
    owner: principal,
    name: (string-ascii 64),
    capabilities: (list 10 (string-ascii 32)),
    status: (string-ascii 20)
  }
)

;; Public Functions

;; Register a new drone
(define-public (register-drone (name (string-ascii 64)) (capabilities (list 10 (string-ascii 32))))
  (let
    (
      (new-drone-id (+ (var-get last-drone-id) u1))
    )
    (asserts! (is-none (map-get? drones { drone-id: new-drone-id })) err-already-registered)
    (map-set drones
      { drone-id: new-drone-id }
      {
        owner: tx-sender,
        name: name,
        capabilities: capabilities,
        status: "idle"
      }
    )
    (var-set last-drone-id new-drone-id)
    (ok new-drone-id)
  )
)

;; Update drone status
(define-public (update-drone-status (drone-id uint) (new-status (string-ascii 20)))
  (let
    (
      (drone (unwrap! (map-get? drones { drone-id: drone-id }) err-not-found))
    )
    (asserts! (is-eq tx-sender (get owner drone)) err-owner-only)
    (map-set drones
      { drone-id: drone-id }
      (merge drone { status: new-status })
    )
    (ok true)
  )
)

;; Read-only Functions

;; Get drone details
(define-read-only (get-drone (drone-id uint))
  (map-get? drones { drone-id: drone-id })
)

;; Get the last drone ID
(define-read-only (get-last-drone-id)
  (ok (var-get last-drone-id))
)

