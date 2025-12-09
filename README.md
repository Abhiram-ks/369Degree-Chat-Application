
![image alt](https://github.com/Abhiram-ks/369Degree-Chat-Application/blob/e45a629cf77610b370bcc9933f61547ce7205962/369degreeDetailview.png)

# 369Degree : Webchat Application
# About project : 
A fully featured real-time chat application built with Flutter, following Clean Architecture and SOLID principles. It integrates REST API, WebSocket communication, SQL database storage, and optimized image caching. The app includes real-time chat windows, dynamic chat tails, user management, message bubbles, live socket connection indicators (connect/disconnect), and typing indicators. Comprehensive Unit, Widget, and Integration tests ensure reliability, scalability, and maintainability.

# Project Overview : 
This project is a fully featured real-time chat application designed with a strong focus on user engagement, scalability, and stable WebSocket communication. It provides a dynamic chatting experience powered by REST APIs, WebSocket events, and robust local data handling. The architecture prioritizes maintainability, reliability, and performance, ensuring smooth real-time updates and offline support.

# Key Features : 
- Stable WebSocket communication with real-time message updates
- Dynamic chat windows & interactive chat tails
- REST API integration for user and data management
API Source: https://mocki.io/fake-json-api
- Local SQL database to store user data, enabling instant access and offline usage
- Optimized image caching to improve performance and reduce network load
- Automatic offline asset handling with proper storage permissions
- Real-time socket indicators (connected/disconnected)
- Typing indicators for improved user experience
- Message bubbles with clean UI/UX design
- WebSocket Events Using the WebSocket echo server
WebSocket Source: https://websocket.org/
- for real-time event handling, message streaming, and connectivity detection.
- Testing follows official Flutter guidelines:
Testing Source: https://docs.flutter.dev/cookbook/testing
- Unit Tests / Widget Tests / Integration Tests
- Coverage for API calls, database logic, BLoC states, and UI behavior

# Data Flow : 

                   PRESENTATION LAYER  
          (UI Components, BLoC/Cubit, Pages, Widgets)                
                           │
                           ↓
                           
                     DOMAIN LAYER                           
    (Entities, UseCases, Repository Interfaces)                
                           │
                           ↓
                           
                       DATA LAYER                            
    (Models, DataSources, Repository Implementations)          
            /                 |                   \
           │                  │                    │
           ↓                  ↓                    ↓
    [Remote API]          [WebSocket]          [Local DB]

# Tools & Technologies : 
Flutter, Dart, Clean Architecture, SOLID Principles, BLoC/Cubit State Management, Dio (HTTP Client), WebSocket (Echo Server / Event-based Communication), REST API (Mocki.io), Local Database (SQFlite/SQLite), Image Caching, and Unit, Widget, and Integration Testing.





