# Monjez Fin: AI-Powered Financial Management Suite

<p align="center">
  <img src="assets/logo.jpg" width="150" alt="Monjez Fin Logo" />
</p>

Monjez Fin is a professional financial management application specifically designed to empower freelancers and small business owners. The platform streamlines financial workflows through advanced AI integration and real-time automation.

## Project Overview
The application addresses the core challenges faced by freelancers in invoice management and payment tracking. By leveraging cutting-edge Artificial Intelligence, Monjez Fin allows users to generate comprehensive invoices via voice commands, significantly reducing manual data entry and improving operational efficiency.

---

## Core Features

### AI-Driven Voice Invoicing
- **Cloud-Powered Intelligence:** Leverages advanced online processing (Google Gemini) to transform voice commands into structured invoice data with high precision.
- **Natural Language Processing:** Intelligent extraction of client names, amounts, service types, and contact information from a single voice command.
- **Arabic Language Optimization:** Advanced processing for various Arabic dialects to ensure high accuracy in data capture.

### Automatic Real-time Payment Tracking
- **Instant Synchronization:** The system automatically updates the status of invoices in real-time as soon as a payment is confirmed via the integrated web payment gateway.
- **Automated Workflow:** Invoices are dynamically transitioned to the "Paid" status upon transaction completion, triggered via Firebase Realtime Database.
- **Immediate Notifications:** Users receive instant system alerts and auditory confirmation upon successful receipt of payments.

### Security and Data Integrity
- **Biometric Authentication:** Secure access to financial records via fingerprint and biometric validation.
- **Cloud-Based Resilience:** All financial data and invoice records are securely synchronized and backed up using Firebase infrastructure.

### Comprehensive Financial Analytics
- **Full Client Tracking:** Advanced analytics that monitor all client interactions, categorizing both frequent and occasional (rare) clients to help freelancers understand their business growth.
- **Invoice Management:** Detailed reporting for all invoices, providing insights into total revenue, outstanding balances, and expenditure through interactive visual charts.

---

## Technology Stack
- **Framework:** Flutter (Dart)
- **Backend Services:** Firebase (Authentication, Realtime Database, Hosting)
- **Artificial Intelligence:** Google Generative AI (Gemini 2.0 Flash) & Custom Local NLP
- **Notification Systems:** Awesome Notifications & Flutter Local Notifications
- **Document Services:** PDF Generation & Printing Integration

---

## Application Screenshots

| Main Dashboard | Invoice Details | AI Interface |
|:---:|:---:|:---:|
| <img src="https://raw.githubusercontent.com/GhofranAl-shahri/monjez-_fin-_app/master/screenshots/1.png" width="250"> | <img src="https://raw.githubusercontent.com/GhofranAl-shahri/monjez-_fin-_app/master/screenshots/2.png" width="250"> | <img src="https://raw.githubusercontent.com/GhofranAl-shahri/monjez-_fin-_app/master/screenshots/3.png" width="250"> |

### Feature Highlights
<p align="center">
  <img src="https://raw.githubusercontent.com/GhofranAl-shahri/monjez-_fin-_app/master/screenshots/4.png" width="180">
  <img src="https://raw.githubusercontent.com/GhofranAl-shahri/monjez-_fin-_app/master/screenshots/5.png" width="180">
  <img src="https://raw.githubusercontent.com/GhofranAl-shahri/monjez-_fin-_app/master/screenshots/6.png" width="180">
  <img src="https://raw.githubusercontent.com/GhofranAl-shahri/monjez-_fin-_app/master/screenshots/7.png" width="180">
</p>

---

## Getting Started

1. **Clone the Repository:**
   ```bash
   git clone https://github.com/GhofranAl-shahri/monjez-_fin-_app.git
   ```
2. **Install Dependencies:**
   ```bash
   flutter pub get
   ```
3. **Configuration:** Ensure the `google-services.json` file is correctly placed in the `android/app` directory.
4. **Execution:**
   ```bash
   flutter run
   ```

---

## Contributors
This project was developed with dedication by:
- Ghofran Al-shehari
- Rehab Sabr
- Sondos Alkenai
- Areej Aljofi

---

**Developed by the Monjez Fin Team**
