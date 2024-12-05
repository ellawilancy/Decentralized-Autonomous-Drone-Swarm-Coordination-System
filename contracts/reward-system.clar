;; Reward System Contract

;; Constants
(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-not-found (err u101))
(define-constant err-insufficient-balance (err u102))

;; Fungible Token
(define-fungible-token drone-token)

;; Data Maps
(define-map user-balances principal uint)

;; Public Functions

;; Mint tokens (only contract owner)
(define-public (mint-tokens (amount uint) (recipient principal))
  (begin
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    (ft-mint? drone-token amount recipient)
  )
)

;; Reward user for completing a task
(define-public (reward-task-completion (user principal) (amount uint))
  (begin
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    (ft-mint? drone-token amount user)
  )
)

;; Reward user for innovation in swarm tactics
(define-public (reward-innovation (user principal) (amount uint))
  (begin
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    (ft-mint? drone-token amount user)
  )
)

;; Transfer tokens between users
(define-public (transfer-tokens (amount uint) (sender principal) (recipient principal))
  (begin
    (asserts! (is-eq tx-sender sender) err-owner-only)
    (ft-transfer? drone-token amount sender recipient)
  )
)

;; Read-only Functions

;; Get user balance
(define-read-only (get-balance (user principal))
  (ok (ft-get-balance drone-token user))
)

;; Get total supply
(define-read-only (get-total-supply)
  (ok (ft-get-supply drone-token))
)

