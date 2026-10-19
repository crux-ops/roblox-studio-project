--!strict
-- Pure limiter; monotonic seconds are supplied by the server, never by clients.
export type Bucket = { Tokens: number, At: number }
local Bucket = {}
function Bucket.New(capacity: number, now: number): Bucket
	return { Tokens = capacity, At = now }
end
function Bucket.Take(bucket: Bucket, capacity: number, refill: number, now: number): boolean
	bucket.Tokens = math.min(capacity, bucket.Tokens + math.max(0, now - bucket.At) * refill)
	bucket.At = math.max(bucket.At, now)
	if bucket.Tokens < 1 then return false end
	bucket.Tokens -= 1
	return true
end
return Bucket
