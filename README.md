# BarberHub: Operations & Scheduling Platform (iOS)

## Operational Summary
A full-stack, production-deployed iOS application architected to manage the daily operations, scheduling, and payment processing for salon and barbershop environments. Originally deployed to the Apple App Store, the platform features strict Role-Based Access Control (RBAC), real-time database synchronization, and third-party financial API integration.

## Tech Stack
* **Frontend Client:** Swift, UIKit, Xcode
* **Backend Architecture:** Firebase (Authentication, Realtime Database)
* **Third-Party APIs:** Square API (Payment Processing & Account Linking)
* **Services:** Apple Push Notification Service (APNs), CocoaPods

## System Architecture & Features

### 1. Role-Based Access Control (RBAC)
The system architecture enforces strict user partitioning based on authentication tiers:
* **Manager Node:** Full administrative clearance. Can dynamically add/remove employee accounts, view global operational schedules, and manage shop-level configurations. 
* **Employee Node:** Restricted access. Can view individual appointment matrices, manage profile metadata, and cancel scheduled appointments directly impacting their queue.
* **Client Node:** End-user facing. Can view availability and book appointments dynamically.

### 2. Backend & Payment Integration
* **Real-Time State Management:** Leveraged Firebase to ensure zero-latency synchronization across all user nodes (e.g., when a client books a slot, it immediately locks out on the employee and manager views).
* **Square API Integration (`payment_backend`):** Engineered a secure handshake between the app and the Square ecosystem, allowing employee accounts to link directly to verified Square POS accounts for secure transaction processing. 

### 3. Push Architecture
* **`NotificationService`:** Implemented custom APNs payloads to handle asynchronous alerts for appointment updates and system notifications.

## Execution Parameters

### Local Deployment
To run the project locally via the Xcode Simulator:
1. Clone the repository.
2. Install dependencies via CocoaPods (if required, run `pod install`).
3. Open the `.xcworkspace` file (not the `.xcodeproj`).
4. Ensure a valid `GoogleService-Info.plist` is present to connect to the Firebase instance.

### System Test Credentials
*(Note: These are sandbox credentials for architecture demonstration purposes).*

**Manager Authorization:**
* **Email:** `manager@manager.com`
* **Password:** `manager12345`

**Employee Authorization:**
* **Email:** `test89@test.com`
* **Password:** `test12345`
*(Registration Code for new employee creation: `AnotherBarbershopId`)*
