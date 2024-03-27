@startuml
concise "Inqvine" as I
concise "The 5GS" as GS
concise "Client" as C

@0
C is {-}
GS is {-}
I is {-}

@8
C is Now
GS is Now
I is Now

@9
C is {-}
GS is {-}
I is "Adding analytics events 4.2"

@15
I is "Implementing persona based on client specification 3.2"
C is "Confirmation of app persona? 2.1"

@22
I is "Start adding receipt functionality"
C is "Prize mechanics confirmed"

@27
C is {-}
GS is {-}

@29
I is "Integration of prize mechanics"

@36
I is "Deployment into client infrastructure 1.4"

@43
I is "Bug fixing and QA 3.3"

@69
C is {-}
GS is {-}
I is {-}

@56
C is "Final feedback point 3.5"
I is "First UAT deployment 2.6"

@63
I is "Target code freeze after tweaks 2.5"
C is "UAT 2.3 3.4"
GS is "UAT 2.3 3.4"

@70
C is "Launch 3.1 3.6 3.7"
GS is "Launch 3.1 3.6 3.7"
I is "Launch 3.1 3.6 3.7"

@71
I is "Monitoring"
GS is "Monitoring"
@enduml