Prompt 1
Act as a Senior Backend & AI Systems Engineer. In Flutter/Dart, create a `RateEngineService` with a `calculateDynamicRate` method that calculates parking fees based on:
1. Vehicle Differentiation: Base rate of ₹40/hr for Cars (4-wheelers) and ₹20/hr for Bikes/Motorcycles (2-wheelers).
2. Time-of-Day Multipliers: +25% surge during peak campus rush (9:00 AM – 12:00 PM), -25% discount during off-peak hours (after 5:00 PM and before 7:00 AM), and 1.0x during standard hours.
3. Occupancy Surge Factor: Query Firestore to calculate live parking occupancy; if occupancy >= 80%, apply an additional +20% surge factor.
4. GenAI Chain-of-Thought Rationale: Return a `RateDetails` object containing a step-by-step pricing breakdown, surge explanation reason, and an actionable user savings tip (e.g., "Park after 12 PM to save 20%").
Provide clean error handling and structured JSON output.


Prompt 2
Design a production-grade LLM Prompt Engineering template in Dart (`getPromptEngineeringTemplate`) to integrate an AI pricing microservice. It must define:
- [SYSTEM PROMPT]: Role as PARK30 Dynamic Pricing Engine.
- [INPUT CONTEXT]: Vehicle type, requested parking time, and current campus occupancy %.
- [FEW-SHOT EXAMPLES]: Step-by-step arithmetic chain-of-thought calculation.
- [RESPONSE FORMAT]: Strict JSON schema with keys: `finalRate`, `surgeLabel`, `tip`, and `rationale`.


Prompt 3
Build an interactive Flutter widget `TimerCard` that tracks a parking reservation in real time:
1. Fetch the exact `bookingEndTime` from the Firestore `parkingSpots/{spotId}` document with fallback calculations.
2. Maintain a 1-second periodic ticker calculating remaining time (`Duration`).
3. Display a neon-styled circular / linear progress bar changing color dynamically (Cyan -> Amber -> Urgent Red when < 10 mins).
4. Trigger a 5-minute warning notification alert before expiry with options to extend the session or navigate to checkout.
5. Include an "End Session & Pay" action that launches receipt generation and frees up the spot in Firestore.


Prompt 4
Create a modern, dark-themed (`0xFF0A0E21`) `ParkingMapScreen` in Flutter supporting Car and Bike zones:
1. Render custom layout overlays (`assets/car_parking_map.png` / `assets/motorcycle_parking_map.png`) with interactive touch targets for individual parking slots.
2. Connect to Firestore streams to update slot status (`available`, `booked`, `maintenance`) in real time with glowing green/red indicators.
3. Add a top status bar displaying available vs occupied capacity.
4. Add an external navigation action button using `url_launcher` that opens Google Maps with campus GPS coordinates.


Prompt 5
Design a bottom sheet / modal in Flutter that appears when an available spot is tapped:
- Display spot details (Slot ID, Zone, Vehicle compatibility).
- Provide a duration picker (1 hr, 2 hrs, 3 hrs, or custom).
- Call `RateEngineService` dynamically to preview the calculated fee, active surge/discount badges, and AI savings tips before confirmation.
- Direct the user to the `PaymentScreen` upon confirmation.


Prompt 6
Create a Flutter `PaymentScreen` with a sleek fintech aesthetic:
1. Accept dynamic `amount` and `spotName` parameters.
2. Provide selectable payment methods: UPI / QR Code and Credit/Debit Card with animated selection borders.
3. Include an asynchronous payment processing animation with loading indicators and error resilience.
4. On success, return confirmation back to the booking flow and trigger receipt generation.


Prompt 7
Implement `ReceiptService` and `EmailService` in Dart:
1. Generate formatted transaction receipts with booking ID, vehicle number, timestamp, rate breakdown, duration, and total amount.
2. Dispatch a confirmation email to the authenticated user's registered address upon successful checkout.
3. Save the transaction log to the Firestore `bookingHistory` collection.


Prompt 8
Refactor Flutter Firebase data layer into clean repository patterns:
1. `AuthRepository`: Encapsulate login, signup, password reset, session persistence, and user profile metadata fetching.
2. `ParkingRepository`: Encapsulate parking spot CRUD operations, atomic slot reservation transactions in Firestore, slot release, and occupancy percentage queries.
3. Ensure proper separation of concerns between UI Screens, Repositories, and Services.





