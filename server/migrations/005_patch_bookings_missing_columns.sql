-- Migration: Patch Bookings Table - Add Missing Columns
-- Description: Adds host_id, booking_type, price_breakdown, payment_status, special_requests
-- to the bookings table to match the application controller expectations.
-- Date: 2026-05-28
-- Fixes: 500 error "column host_id of relation bookings does not exist"

-- Add host_id column (references the listing owner)
ALTER TABLE bookings ADD COLUMN IF NOT EXISTS host_id UUID REFERENCES users(id) ON DELETE SET NULL;

-- Add booking_type column (instant vs standard)
ALTER TABLE bookings ADD COLUMN IF NOT EXISTS booking_type VARCHAR(50) DEFAULT 'standard';

-- Add price_breakdown column (JSONB with detailed pricing)
ALTER TABLE bookings ADD COLUMN IF NOT EXISTS price_breakdown JSONB;

-- Add payment_status column
ALTER TABLE bookings ADD COLUMN IF NOT EXISTS payment_status VARCHAR(50) DEFAULT 'unpaid';

-- Add special_requests column
ALTER TABLE bookings ADD COLUMN IF NOT EXISTS special_requests TEXT;

-- Backfill host_id from listings for any existing bookings
UPDATE bookings b
SET host_id = l.host_id
FROM listings l
WHERE b.listing_id = l.id
AND b.host_id IS NULL;

-- Create index on host_id for efficient host-side queries
CREATE INDEX IF NOT EXISTS idx_bookings_host_id ON bookings(host_id);
