;; Swarm Behavior Contract

;; Constants
(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-not-found (err u101))
(define-constant err-invalid-behavior (err u102))

;; Data Maps
(define-map swarm-behaviors
  { behavior-id: uint }
  {
    name: (string-ascii 64),
    description: (string-utf8 256),
    rules: (list 10 (string-utf8 256))
  }
)

(define-data-var last-behavior-id uint u0)

;; Public Functions

;; Define a new swarm behavior
(define-public (define-swarm-behavior (name (string-ascii 64)) (description (string-utf8 256)) (rules (list 10 (string-utf8 256))))
  (let
    (
      (new-behavior-id (+ (var-get last-behavior-id) u1))
    )
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    (map-set swarm-behaviors
      { behavior-id: new-behavior-id }
      {
        name: name,
        description: description,
        rules: rules
      }
    )
    (var-set last-behavior-id new-behavior-id)
    (ok new-behavior-id)
  )
)

;; Update an existing swarm behavior
(define-public (update-swarm-behavior (behavior-id uint) (name (string-ascii 64)) (description (string-utf8 256)) (rules (list 10 (string-utf8 256))))
  (let
    (
      (behavior (unwrap! (map-get? swarm-behaviors { behavior-id: behavior-id }) err-not-found))
    )
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    (map-set swarm-behaviors
      { behavior-id: behavior-id }
      {
        name: name,
        description: description,
        rules: rules
      }
    )
    (ok true)
  )
)

;; Read-only Functions

;; Get swarm behavior details
(define-read-only (get-swarm-behavior (behavior-id uint))
  (map-get? swarm-behaviors { behavior-id: behavior-id })
)

;; Get the last behavior ID
(define-read-only (get-last-behavior-id)
  (ok (var-get last-behavior-id))
)

