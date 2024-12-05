;; Task Allocation Contract

;; Constants
(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-not-found (err u101))
(define-constant err-invalid-task (err u102))

;; Data Variables
(define-data-var last-task-id uint u0)

;; Data Maps
(define-map tasks
  { task-id: uint }
  {
    mission-id: uint,
    drone-id: uint,
    task-type: (string-ascii 32),
    status: (string-ascii 20),
    priority: uint,
    start-time: uint,
    end-time: uint
  }
)

(define-map mission-tasks
  { mission-id: uint }
  (list 100 uint)
)

(define-map drone-tasks
  { drone-id: uint }
  (list 100 uint)
)

;; Public Functions

;; Create a new task
(define-public (create-task (mission-id uint) (drone-id uint) (task-type (string-ascii 32)) (priority uint) (start-time uint) (end-time uint))
  (let
    (
      (new-task-id (+ (var-get last-task-id) u1))
      (mission-task-list (default-to (list) (map-get? mission-tasks { mission-id: mission-id })))
      (drone-task-list (default-to (list) (map-get? drone-tasks { drone-id: drone-id })))
    )
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    (map-set tasks
      { task-id: new-task-id }
      {
        mission-id: mission-id,
        drone-id: drone-id,
        task-type: task-type,
        status: "pending",
        priority: priority,
        start-time: start-time,
        end-time: end-time
      }
    )
    (map-set mission-tasks { mission-id: mission-id } (unwrap! (as-max-len? (append mission-task-list new-task-id) u100) err-invalid-task))
    (map-set drone-tasks { drone-id: drone-id } (unwrap! (as-max-len? (append drone-task-list new-task-id) u100) err-invalid-task))
    (var-set last-task-id new-task-id)
    (ok new-task-id)
  )
)

;; Update task status
(define-public (update-task-status (task-id uint) (new-status (string-ascii 20)))
  (let
    (
      (task (unwrap! (map-get? tasks { task-id: task-id }) err-not-found))
    )
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    (asserts! (or (is-eq new-status "in-progress") (is-eq new-status "completed") (is-eq new-status "failed")) err-invalid-task)
    (map-set tasks
      { task-id: task-id }
      (merge task { status: new-status })
    )
    (ok true)
  )
)

;; Read-only Functions

;; Get task details
(define-read-only (get-task (task-id uint))
  (map-get? tasks { task-id: task-id })
)

;; Get tasks for a specific mission
(define-read-only (get-mission-tasks (mission-id uint))
  (ok (map-get? mission-tasks { mission-id: mission-id }))
)

;; Get tasks for a specific drone
(define-read-only (get-drone-tasks (drone-id uint))
  (ok (map-get? drone-tasks { drone-id: drone-id }))
)

;; Get the last task ID
(define-read-only (get-last-task-id)
  (ok (var-get last-task-id))
)

