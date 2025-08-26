;; Curb Repair Coordination Contract
;; Manages repair and replacement of damaged concrete curbing

;; Constants
(define-constant CONTRACT-OWNER tx-sender)
(define-constant ERR-NOT-AUTHORIZED (err u100))
(define-constant ERR-INVALID-INPUT (err u101))
(define-constant ERR-NOT-FOUND (err u102))
(define-constant ERR-ALREADY-EXISTS (err u103))
(define-constant ERR-INVALID-STATUS (err u104))

;; Data Variables
(define-data-var next-repair-id uint u1)
(define-data-var total-repairs uint u0)
(define-data-var total-cost uint u0)

;; Data Maps
(define-map repairs
  uint
  {
    location: (string-ascii 100),
    coordinates: {x: uint, y: uint},
    description: (string-ascii 500),
    priority: uint,
    status: uint,
    reporter: principal,
    contractor: (optional principal),
    estimated-cost: uint,
    actual-cost: uint,
    created-at: uint,
    completed-at: (optional uint)
  }
)

(define-map contractor-ratings
  principal
  {
    total-jobs: uint,
    completed-jobs: uint,
    average-rating: uint,
    total-earnings: uint
  }
)

;; Public Functions

;; Report damaged curbing
(define-public (report-damage (repair-data {location: (string-ascii 100), coordinates: {x: uint, y: uint}, description: (string-ascii 500), priority: uint}))
  (let ((repair-id (var-get next-repair-id))
        (location (get location repair-data))
        (coordinates (get coordinates repair-data))
        (description (get description repair-data))
        (priority (get priority repair-data)))
    (asserts! (< priority u4) ERR-INVALID-INPUT)
    (asserts! (> (len location) u0) ERR-INVALID-INPUT)
    (asserts! (> (len description) u0) ERR-INVALID-INPUT)

    (map-set repairs repair-id
      {
        location: location,
        coordinates: coordinates,
        description: description,
        priority: priority,
        status: u0,
        reporter: tx-sender,
        contractor: none,
        estimated-cost: u0,
        actual-cost: u0,
        created-at: block-height,
        completed-at: none
      }
    )

    (var-set next-repair-id (+ repair-id u1))
    (var-set total-repairs (+ (var-get total-repairs) u1))
    (ok repair-id)
  )
)

;; Assign contractor to repair job
(define-public (assign-contractor (assignment-data {repair-id: uint, contractor: principal, estimated-cost: uint}))
  (let ((repair-id (get repair-id assignment-data))
        (contractor (get contractor assignment-data))
        (estimated-cost (get estimated-cost assignment-data))
        (repair (unwrap! (map-get? repairs repair-id) ERR-NOT-FOUND)))
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
    (asserts! (is-eq (get status repair) u0) ERR-INVALID-STATUS)
    (asserts! (> estimated-cost u0) ERR-INVALID-INPUT)

    (map-set repairs repair-id
      (merge repair {
        contractor: (some contractor),
        estimated-cost: estimated-cost,
        status: u1
      })
    )
    (ok true)
  )
)

;; Start repair work
(define-public (start-repair (repair-id uint))
  (let ((repair (unwrap! (map-get? repairs repair-id) ERR-NOT-FOUND)))
    (asserts! (is-eq (some tx-sender) (get contractor repair)) ERR-NOT-AUTHORIZED)
    (asserts! (is-eq (get status repair) u1) ERR-INVALID-STATUS)

    (map-set repairs repair-id
      (merge repair {status: u2})
    )
    (ok true)
  )
)

;; Complete repair work
(define-public (complete-repair (completion-data {repair-id: uint, actual-cost: uint}))
  (let ((repair-id (get repair-id completion-data))
        (actual-cost (get actual-cost completion-data))
        (repair (unwrap! (map-get? repairs repair-id) ERR-NOT-FOUND)))
    (asserts! (is-eq (some tx-sender) (get contractor repair)) ERR-NOT-AUTHORIZED)
    (asserts! (is-eq (get status repair) u2) ERR-INVALID-STATUS)
    (asserts! (> actual-cost u0) ERR-INVALID-INPUT)

    (map-set repairs repair-id
      (merge repair {
        status: u3,
        actual-cost: actual-cost,
        completed-at: (some block-height)
      })
    )

    (var-set total-cost (+ (var-get total-cost) actual-cost))
    (update-contractor-stats (unwrap-panic (get contractor repair)) actual-cost)
    (ok true)
  )
)

;; Rate completed repair
(define-public (rate-repair (rating-data {repair-id: uint, rating: uint}))
  (let ((repair-id (get repair-id rating-data))
        (rating (get rating rating-data))
        (repair (unwrap! (map-get? repairs repair-id) ERR-NOT-FOUND)))
    (asserts! (is-eq tx-sender (get reporter repair)) ERR-NOT-AUTHORIZED)
    (asserts! (is-eq (get status repair) u3) ERR-INVALID-STATUS)
    (asserts! (and (>= rating u1) (<= rating u5)) ERR-INVALID-INPUT)

    (match (get contractor repair)
      contractor (update-contractor-rating contractor rating)
      false
    )
    (ok true)
  )
)

;; Read-only Functions

(define-read-only (get-repair (repair-id uint))
  (map-get? repairs repair-id)
)

(define-read-only (get-contractor-stats (contractor principal))
  (map-get? contractor-ratings contractor)
)

(define-read-only (get-total-repairs)
  (var-get total-repairs)
)

(define-read-only (get-total-cost)
  (var-get total-cost)
)

;; Private Functions

(define-private (update-contractor-stats (contractor principal) (cost uint))
  (let ((current-stats (default-to {total-jobs: u0, completed-jobs: u0, average-rating: u0, total-earnings: u0}
                                  (map-get? contractor-ratings contractor))))
    (map-set contractor-ratings contractor
      (merge current-stats {
        completed-jobs: (+ (get completed-jobs current-stats) u1),
        total-earnings: (+ (get total-earnings current-stats) cost)
      })
    )
  )
)

(define-private (update-contractor-rating (contractor principal) (rating uint))
  (let ((current-stats (unwrap-panic (map-get? contractor-ratings contractor))))
    (let ((total-jobs (get total-jobs current-stats))
          (current-avg (get average-rating current-stats)))
      (let ((new-avg (/ (+ (* current-avg total-jobs) rating) (+ total-jobs u1))))
        (map-set contractor-ratings contractor
          (merge current-stats {
            total-jobs: (+ total-jobs u1),
            average-rating: new-avg
          })
        )
      )
    )
  )
)
