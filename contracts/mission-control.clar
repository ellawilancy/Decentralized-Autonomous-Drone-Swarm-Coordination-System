;; Mission Control Contract

;; Constants
(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-not-found (err u101))
(define-constant err-invalid-status (err u102))

;; Data Variables
(define-data-var last-mission-id uint u0)

;; Data Maps
(define-map missions
  { mission-id: uint }
  {
    name: (string-ascii 64),
    description: (string-utf8 256),
    behavior-id: uint,
    status: (string-ascii 20),
    start-time: uint,
    end-time: uint,
    assigned-drones: (list 100 uint)
  }
)

;; Public Functions

;; Create a new mission
(define-public (create-mission (name (string-ascii 64)) (description (string-utf8 256)) (behavior-id uint) (start-time uint) (end-time uint))
  (let
    (
      (new-mission-id (+ (var-get last-mission-id) u1))
    )
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    (map-set missions
      { mission-id: new-mission-id }
      {
        name: name,
        description: description,
        behavior-id: behavior-id,
        status: "pending",
        start-time: start-time,
        end-time: end-time,
        assigned-drones: (list)
      }
    )
    (var-set last-mission-id new-mission-id)
    (ok new-mission-id)
  )
)

;; Update mission status
(define-public (update-mission-status (mission-id uint) (new-status (string-ascii 20)))
  (let
    (
      (mission (unwrap! (map-get? missions { mission-id: mission-id }) err-not-found))
    )
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    (asserts! (or (is-eq new-status "active") (is-eq new-status "completed") (is-eq new-status "aborted")) err-invalid-status)
    (map-set missions
      { mission-id: mission-id }
      (merge mission { status: new-status })
    )
    (ok true)
  )
)

;; Assign drones to a mission
(define-public (assign-drones-to-mission (mission-id uint) (drone-ids (list 100 uint)))
  (let
    (
      (mission (unwrap! (map-get? missions { mission-id: mission-id }) err-not-found))
    )
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    (map-set missions
      { mission-id: mission-id }
      (merge mission { assigned-drones: drone-ids })
    )
    (ok true)
  )
)

;; Read-only Functions

;; Get mission details
(define-read-only (get-mission (mission-id uint))
  (map-get? missions { mission-id: mission-id })
)

;; Get the last mission ID
(define-read-only (get-last-mission-id)
  (ok (var-get last-mission-id))
)

