# PCI App

Welcome to the PCI App being developed jointly by Unnat Maharashtra Abhiyan, IIT Bombay and Zilla Parishad, Ratnagiri.

As we know, roads are being built in India at a rapid pace. Given that, ensuring that these roads meet a certain quality is of great importance. While there are expensive machines to test road quality, there is no simple technology to reliably test and log road quality.

This project aims to contribute to change this by automating the assessment of road pavement conditions using an App.

## Contents
- [Overview](#1-overview)
- [Goals](#2-goals)
- [Intallation](#3-installation)
- [Folder Structure](#4-folder-structure)

## 1. Overview

The project uses the Android smartphone as its basic platform. By utilizing in-built smartphone sensors such as accelerometers and GPS, along with textual inputs like pothole counts, PCI App aims to compute the Pavement Condition Index (PCI). The PCI will serve as a crucial parameter for informing both the engineer as well as the citizen about the quality of the road.

## 2. Goals

- Develop software to gather sensor data systematically.
- Formulate a data model to relate raw sensor data to the PCI
- Automate the assessment of road pavement conditions
- Develop a mobile app for data collection
- Create a central database for storage and analysis

## 3. Installation

### Prerequisites

- Flutter 3.32.0 (or the latest version)
- Dark SDK
- Android Studio (latest version preffered)
- Firebase project setup (this will automatically setup the google cloud project in your cloud console). Contact admin if the project is already setup on cloud to to become a collaborator.
- GetX has been used for the state management : [getting started with getX](https://chornthorn.github.io/getx-docs/docs)

### Steps

1. clone the repo
   ```bash
   git clone https://github.com/vk7061iitb/PCI-App.git
   cd PCI-App
   ```
2. run `flutter pub get` to install the dependencies
3. **Note:** The configuration and API keys are not on github.

   - The app uses google maps to show the road network. A google maps API can be generated using google cloud console.
     Paste the API key in folder : `/android/local.properties`

   ```bash
   G_MAP_KEY=YOUR_GMAPS_API_KEY
   ```

   - Write your all the API endpoints in file : `lib/src/config/config.dart`

   ```dart
   class Config {
   static const baseURL = "https://myapp.com/";
   static const sendDataEndPoint = "send-data-endpoint";
   static const loginEndPoint = "login-endpoint";
   static const signUpEndpoint = "signup-endpoint";
   static const reportPdfEndPoint = "report-endpoint";
   static String getAuthBaseURL() => "https://pcibackend.xyz/";
   }
   ```

## 4. Folder Structure

```bash
lib/
├── Assets/ # contains the icons used
├── Fuctions/        
├── Objects/ 
│   └── data.dart # contains the global varibale and Objects
├── Utils/
└── src/
    ├── API/ # login and signup functions
    ├── config/ # api endpoints
    ├── Database/ # contains the db helper class 
    ├── Models/ 
    ├── Presentation/ # contains the screens widget 
    │   ├── Controllers/ # getX controllers for different screens
    │   └── Screens/
    └── service/
```

## 5 Licence
This project is licensed under the Apache License - see the [LICENSE](LICENSE) file for details.
