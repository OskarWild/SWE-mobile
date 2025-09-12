# Supplier-Consumer Platform: Mobile Application
This repository contains the source code for the two-sided mobile application of the Supplier-Consumer Platform, developed using the Flutter framework. This single codebase is deployed to both iOS and Android, serving two primary user roles: Consumers (restaurants and hotels) and Suppliers (farmers, producers, and distributors).

Key Features
The mobile apps are designed to facilitate B2B transactions and communication within the food supply chain.

For Consumers (Restaurants & Hotels)
Discovery & Linking: Consumers can find and send "link" requests to suppliers. Visibility of a supplier's catalog and pricing is granted only after a link request is accepted.

Catalog Viewing: Browse and search for food products (e.g., dairy, meat, fish) from linked suppliers.

Ordering: Create and manage bulk orders.

Complaint Handling: Initiate complaint or return requests directly from an order detail page.

For Suppliers (Farmers & Producers)
Roles & Permissions: The app supports distinct user roles within a supplier's organization: Owner, Admin, and Sales, each with specific permissions for managing the account, inventory, and customer interactions.

Storefront & Catalog Management: Create, edit, and manage product listings, including pricing, stock levels, and minimum order quantities.

Order Management: Accept or reject bulk orders and update stock in real-time.

Subscription Management: An in-app flow for suppliers to manage their subscription to the platform.

Shared Features
Integrated Chat: A WhatsApp-like messaging system for direct communication between linked consumers and suppliers. This includes features like read receipts, typing indicators, and file attachments (photos, documents, audio).

Incident Management: A built-in workflow for Sales representatives to handle consumer complaints and escalate unresolved issues to their Admins.

Localization: The app supports both Kazakh and Russian languages, with a future plan to expand to English and other languages for international markets.

Technology Stack
Framework: Flutter (for a single, cross-platform codebase)

Language: Dart

Deployment: iOS and Android

Backend: REST/GraphQL services (as per the SRS)

Design and Constraints
The mobile app's design adheres to the following constraints from the SRS:

Mandatory Framework: The use of Flutter is mandatory.

Geographic Focus: Initial rollout is in Kazakhstan.

Languages: Primary languages are Kazakh and Russian.

Accessibility: Adherence to WCAG 2.1 AA standards.

MVP Scope
The Minimum Viable Product (MVP) focuses on core functionality to ensure a smooth launch. The following features are excluded from the initial release but are planned for later phases:

In-app payments

Delivery scheduling and logistics coordination

For detailed requirements and future plans, please refer to the full Software Requirements Specification (SRS) document.
