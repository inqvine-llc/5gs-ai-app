@startuml
actor User as U
actor INQVINE as IQV
entity "Client Application" as CA
database WhaPI as W
database WhatsApp as WA
entity "OpenAI/Claude/Gemini" as AI
database Redis as R

note left of AI: The LLM used to generate the text response will eventually be hosted within Deutsche Telekom.
note left of R: Redis will be hosted by Deutsche Telekom for production.

IQV --> CA : Loads configuration file into local/hosted CA
CA --> AI : Load API keys and system environment properties
CA --> W : Load API keys and system environment properties

IQV --> CA : Loads system context messages into client application
note right of IQV : The system context messages will be QA'd and agreed with the client before. This will determine how the AI responds to the end user and is essentially instructions over what will be OpenAI.

U --> CA : User Message
CA --> W : Poll for New Messages
W --> WA : Get New Messages
WA --> CA : New Messages
CA --> AI : Process Message
AI --> CA : Contextual Chat Conversation

alt Reply if not already replied
    CA --> R : Check if replied
    R --> CA : Not Replied
    CA --> WA : Prepare reply
else Already replied
    CA --> R : Check if replied
    R --> CA : Already Replied
end

CA --> R : Check for prizes
alt Prize available
    CA --> U : Perform TBD prize draw mechnical
    alt Prize draw success
        CA --> R : Request prize information
        R --> R : Flag prize as received, storing U details
        R --> CA : Response with prize information
        CA --> CA : Add contextual prize information into response context
    else Prize draw failure
    end
else No prizes available
    CA --> CA : Flag not to include prize context in response
end
@enduml