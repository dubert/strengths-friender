module Strengths exposing (..)

import Dict exposing (Dict)
import List exposing (filter, length)


-- model


type alias Model =
    { strengths : List Strength
    , codes : List Char
    }


type alias Strength =
    { id : Char
    , name : String
    , info : String
    }


initModel : Model
initModel =
    { strengths = strengthList
    , codes = codeList
    }


strengthList : List Strength
strengthList =
    [ { id = 'a'
      , name = "Achiever"
      , info = "People strong in the Achiever theme have a great deal of stamina and work hard. They take great satisfaction from being busy and productive."
      }
    , { id = '2'
      , name = "Activator"
      , info = "People strong in the Activator theme can make things happen by turning thoughts into action. They are often impatient."
      }
    , { id = 'y'
      , name = "Adaptability"
      , info = "People strong in the Adaptability theme prefer to \"go with the flow.\" They tend to be \"now\" people who take things as they come and discover the future one day at a time."
      }
    , { id = 'q'
      , name = "Analytical"
      , info = "People strong in the Analytical theme search for reasons and causes. They have the ability to think about all the factors that might affect a situation."
      }
    , { id = 'j'
      , name = "Arranger"
      , info = "People strong in the Arranger theme can organize, but they also have a flexibility that complements this ability. They like to figure out how all of the pieces and resources can be arranged for maximum productivity."
      }
    , { id = 'b'
      , name = "Belief"
      , info = "People strong in the Belief theme have certain core values that are unchanging. Out of these values emerges a defined purpose for their life."
      }
    , { id = 'k'
      , name = "Command"
      , info = "People strong in the Command theme have presence. They can take control of a situation and make decisions."
      }
    , { id = 'c'
      , name = "Communication"
      , info = "People strong in the Communication theme generally find it easy to put their thoughts into words. They are good conversationalists and presenters."
      }
    , { id = '1'
      , name = "Competition"
      , info = "People strong in the Competition theme measure their progress against the performance of others. They strive to win first place and revel in contests."
      }
    , { id = 'n'
      , name = "Connectedness"
      , info = "People strong in the Connectedness theme have faith in the links between all things. They believe there are few coincidences and that almost every event has a reason."
      }
    , { id = 'o'
      , name = "Consistency"
      , info = "People strong in the Consistency theme are keenly aware of the need to treat people the same. They try to treat everyone in the world fairly by setting up clear rules and adhering to them."
      }
    , { id = 'x'
      , name = "Context"
      , info = "People strong in the Context theme enjoy thinking about the past. They understand the present by researching its history."
      }
    , { id = 'v'
      , name = "Deliberative"
      , info = "People strong in the Deliberative theme are best described by the serious care they take in making decisions or choices. They anticipate the obstacles."
      }
    , { id = 'd'
      , name = "Developer"
      , info = "People strong in the Developer theme recognize and cultivate the potential in others. They spot the signs of each small improvement and derive satisfaction from these improvements."
      }
    , { id = '4'
      , name = "Discipline"
      , info = "People strong in the Discipline theme enjoy routine and structure. Their world is best described by the order they create."
      }
    , { id = 'e'
      , name = "Empathy"
      , info = "People strong in the Empathy theme can sense the feelings of other people by imagining themselves in others' lives or others' situations."
      }
    , { id = 'f'
      , name = "Focus"
      , info = "People strong in the Focus theme can take a direction, follow through, and make the corrections necessary to stay on track. They prioritize, then act."
      }
    , { id = 'u'
      , name = "Futuristic"
      , info = "People strong in the Futuristic theme are inspired by the future and what could be. They inspire others with their visions of the future."
      }
    , { id = 'h'
      , name = "Harmony"
      , info = "People strong in the Harmony theme look for consensus. They don't enjoy conflict; rather, they seek areas of agreement."
      }
    , { id = '3'
      , name = "Ideation"
      , info = "People strong in the Ideation theme are fascinated by ideas. They are able to find connections between seemingly disparate phenomena."
      }
    , { id = '8'
      , name = "Includer"
      , info = "People strong in the Includer theme are accepting of others. They show awareness of those who feel left out, and make an effort to include them."
      }
    , { id = 'i'
      , name = "Individualization"
      , info = "People strong in the Individualization theme are intrigued with the unique qualities of each person. They have a gift for figuring out how people who are different can work together productively."
      }
    , { id = '5'
      , name = "Input"
      , info = "People strong in the Input theme have a craving to know more. Often they like to collect and archive all kinds of information."
      }
    , { id = 't'
      , name = "Intellection"
      , info = "People strong in the Intellection theme are characterized by their intellectual activity. They are introspective and appreciate intellectual discussions."
      }
    , { id = 'l'
      , name = "Learner"
      , info = "People strong in the Learner theme have a great desire to learn and want to continuously improve. In particular, the process of learning, rather than the outcome, excites them."
      }
    , { id = 'm'
      , name = "Maximizer"
      , info = "People strong in the Maximizer theme focus on strengths as a way to stimulate personal and group excellence. They seek to transform something strong into something superb."
      }
    , { id = 'p'
      , name = "Positivity"
      , info = "People strong in the Positivity theme have an enthusiasm that is contagious. They are upbeat and can get others excited about what they are going to do."
      }
    , { id = 'r'
      , name = "Relator"
      , info = "People who are strong in the Relator theme enjoy close relationships with others. They find deep satisfaction in working hard with friends to achieve a goal."
      }
    , { id = 'z'
      , name = "Responsibility"
      , info = "People strong in the Responsibility theme take psychological ownership of what they say they will do. They are committed to stable values such as honesty and loyalty."
      }
    , { id = '7'
      , name = "Restorative"
      , info = "People strong in the Restorative theme are adept at dealing with problems. They are good at figuring out what is wrong and resolving it."
      }
    , { id = '6'
      , name = "Self-Assurance"
      , info = "People strong in the Self-Assurance theme feel confident in their ability to manage their own lives. They possess an inner compass that gives them confidence that their decisions are right."
      }
    , { id = 'g'
      , name = "Significance"
      , info = "People strong in the Significance theme want to be very important in the eyes of others. They are independent and want to be recognized."
      }
    , { id = 's'
      , name = "Strategic"
      , info = "People strong in the Strategic theme create alternative ways to proceed. Faced with any given scenario, they can quickly spot the relevant patterns and issues."
      }
    , { id = 'w'
      , name = "Woo"
      , info = "People strong in the Woo theme love the challenge of meeting new people and winning them over. They derive satisfaction from breaking the ice and making a connection with another person."
      }
    ]


strengthNameList : List String
strengthNameList =
    [ "achiever", "activator", "adaptability", "analytical", "arranger", "belief", "command", "communication", "competition", "connectedness", "consistency", "context", "deliberative", "developer", "discipline", "empathy", "focus", "futuristic", "harmony", "ideation", "includer", "individualization", "input", "intellection", "learner", "maximizer", "positivity", "relator", "responsibility", "restorative", "self-assurance", "significance", "strategic", "woo" ]


strengthDict : Dict Char Strength
strengthDict =
    Dict.fromList
        [ ( 'a'
          , { id = 'a'
            , name = "Achiever"
            , info = "People strong in the Achiever theme have a great deal of stamina and work hard. They take great satisfaction from being busy and productive."
            }
          )
        , ( '2'
          , { id = '2'
            , name = "Activator"
            , info = "People strong in the Activator theme can make things happen by turning thoughts into action. They are often impatient."
            }
          )
        , ( 'y'
          , { id = 'y'
            , name = "Adaptability"
            , info = "People strong in the Adaptability theme prefer to \"go with the flow.\" They tend to be \"now\" people who take things as they come and discover the future one day at a time."
            }
          )
        , ( 'q'
          , { id = 'q'
            , name = "Analytical"
            , info = "People strong in the Analytical theme search for reasons and causes. They have the ability to think about all the factors that might affect a situation."
            }
          )
        , ( 'j'
          , { id = 'j'
            , name = "Arranger"
            , info = "People strong in the Arranger theme can organize, but they also have a flexibility that complements this ability. They like to figure out how all of the pieces and resources can be arranged for maximum productivity."
            }
          )
        , ( 'b'
          , { id = 'b'
            , name = "Belief"
            , info = "People strong in the Belief theme have certain core values that are unchanging. Out of these values emerges a defined purpose for their life."
            }
          )
        , ( 'k'
          , { id = 'k'
            , name = "Command"
            , info = "People strong in the Command theme have presence. They can take control of a situation and make decisions."
            }
          )
        , ( 'c'
          , { id = 'c'
            , name = "Communication"
            , info = "People strong in the Communication theme generally find it easy to put their thoughts into words. They are good conversationalists and presenters."
            }
          )
        , ( '1'
          , { id = '1'
            , name = "Competition"
            , info = "People strong in the Competition theme measure their progress against the performance of others. They strive to win first place and revel in contests."
            }
          )
        , ( 'n'
          , { id = 'n'
            , name = "Connectedness"
            , info = "People strong in the Connectedness theme have faith in the links between all things. They believe there are few coincidences and that almost every event has a reason."
            }
          )
        , ( 'o'
          , { id = 'o'
            , name = "Consistency"
            , info = "People strong in the Consistency theme are keenly aware of the need to treat people the same. They try to treat everyone in the world fairly by setting up clear rules and adhering to them."
            }
          )
        , ( 'x'
          , { id = 'x'
            , name = "Context"
            , info = "People strong in the Context theme enjoy thinking about the past. They understand the present by researching its history."
            }
          )
        , ( 'v'
          , { id = 'v'
            , name = "Deliberative"
            , info = "People strong in the Deliberative theme are best described by the serious care they take in making decisions or choices. They anticipate the obstacles."
            }
          )
        , ( 'd'
          , { id = 'd'
            , name = "Developer"
            , info = "People strong in the Developer theme recognize and cultivate the potential in others. They spot the signs of each small improvement and derive satisfaction from these improvements."
            }
          )
        , ( '4'
          , { id = '4'
            , name = "Discipline"
            , info = "People strong in the Discipline theme enjoy routine and structure. Their world is best described by the order they create."
            }
          )
        , ( 'e'
          , { id = 'e'
            , name = "Empathy"
            , info = "People strong in the Empathy theme can sense the feelings of other people by imagining themselves in others' lives or others' situations."
            }
          )
        , ( 'f'
          , { id = 'f'
            , name = "Focus"
            , info = "People strong in the Focus theme can take a direction, follow through, and make the corrections necessary to stay on track. They prioritize, then act."
            }
          )
        , ( 'u'
          , { id = 'u'
            , name = "Futuristic"
            , info = "People strong in the Futuristic theme are inspired by the future and what could be. They inspire others with their visions of the future."
            }
          )
        , ( 'h'
          , { id = 'h'
            , name = "Harmony"
            , info = "People strong in the Harmony theme look for consensus. They don't enjoy conflict; rather, they seek areas of agreement."
            }
          )
        , ( '3'
          , { id = '3'
            , name = "Ideation"
            , info = "People strong in the Ideation theme are fascinated by ideas. They are able to find connections between seemingly disparate phenomena."
            }
          )
        , ( '8'
          , { id = '8'
            , name = "Includer"
            , info = "People strong in the Includer theme are accepting of others. They show awareness of those who feel left out, and make an effort to include them."
            }
          )
        , ( 'i'
          , { id = 'i'
            , name = "Individualization"
            , info = "People strong in the Individualization theme are intrigued with the unique qualities of each person. They have a gift for figuring out how people who are different can work together productively."
            }
          )
        , ( '5'
          , { id = '5'
            , name = "Input"
            , info = "People strong in the Input theme have a craving to know more. Often they like to collect and archive all kinds of information."
            }
          )
        , ( 't'
          , { id = 't'
            , name = "Intellection"
            , info = "People strong in the Intellection theme are characterized by their intellectual activity. They are introspective and appreciate intellectual discussions."
            }
          )
        , ( 'l'
          , { id = 'l'
            , name = "Learner"
            , info = "People strong in the Learner theme have a great desire to learn and want to continuously improve. In particular, the process of learning, rather than the outcome, excites them."
            }
          )
        , ( 'm'
          , { id = 'm'
            , name = "Maximizer"
            , info = "People strong in the Maximizer theme focus on strengths as a way to stimulate personal and group excellence. They seek to transform something strong into something superb."
            }
          )
        , ( 'p'
          , { id = 'p'
            , name = "Positivity"
            , info = "People strong in the Positivity theme have an enthusiasm that is contagious. They are upbeat and can get others excited about what they are going to do."
            }
          )
        , ( 'r'
          , { id = 'r'
            , name = "Relator"
            , info = "People who are strong in the Relator theme enjoy close relationships with others. They find deep satisfaction in working hard with friends to achieve a goal."
            }
          )
        , ( 'z'
          , { id = 'z'
            , name = "Responsibility"
            , info = "People strong in the Responsibility theme take psychological ownership of what they say they will do. They are committed to stable values such as honesty and loyalty."
            }
          )
        , ( '7'
          , { id = '7'
            , name = "Restorative"
            , info = "People strong in the Restorative theme are adept at dealing with problems. They are good at figuring out what is wrong and resolving it."
            }
          )
        , ( '6'
          , { id = '6'
            , name = "Self-Assurance"
            , info = "People strong in the Self-Assurance theme feel confident in their ability to manage their own lives. They possess an inner compass that gives them confidence that their decisions are right."
            }
          )
        , ( 'g'
          , { id = 'g'
            , name = "Significance"
            , info = "People strong in the Significance theme want to be very important in the eyes of others. They are independent and want to be recognized."
            }
          )
        , ( 's'
          , { id = 's'
            , name = "Strategic"
            , info = "People strong in the Strategic theme create alternative ways to proceed. Faced with any given scenario, they can quickly spot the relevant patterns and issues."
            }
          )
        , ( 'w'
          , { id = 'w'
            , name = "Woo"
            , info = "People strong in the Woo theme love the challenge of meeting new people and winning them over. They derive satisfaction from breaking the ice and making a connection with another person."
            }
          )
        ]


codeList : List Char
codeList =
    [ 'a', '2', 'y', 'q', 'j', 'b', 'k', 'c', '1', 'n', 'o', 'x', 'v', 'd', '4', 'e', 'f', 'u', 'h', '3', '8', 'i', '5', 't', 'l', 'm', 'p', 'r', 'z', '7', '6', 'g', 's', 'w' ]


clean : String -> String
clean text =
    text
        |> String.toLower
        |> String.trim


isStrengthValid : String -> Result String String
isStrengthValid text =
    if List.member (clean text) strengthNameList then
        Ok text
    else
        Err (toString text ++ " is not a valid strength")


getStrengthFromName : String -> Result String Strength
getStrengthFromName name =
    let
        strength =
            filter
                (\s -> (clean s.name) == (clean name))
                strengthList

        result =
            Result.fromMaybe
                (toString name ++ " could not be found")
                (List.head strength)
    in
        if length strength == 1 then
            result
        else
            Err (toString name ++ " is not a valid strength")


getStrengthFromCode : Char -> Result String Strength
getStrengthFromCode code =
    case Dict.get code strengthDict of
        Nothing ->
            Err (toString code ++ " is not a valid strength")

        Just strength ->
            Ok strength


getStrengthNameFromCode : Char -> String
getStrengthNameFromCode code =
    case Dict.get code strengthDict of
        Nothing ->
            ""

        Just strength ->
            strength.name


getStrengthNameListFromCodex : Maybe String -> List String
getStrengthNameListFromCodex maybeCodex =
    case maybeCodex of
        Nothing ->
            []

        Just codex ->
            codex
                |> String.toList
                |> List.map getStrengthNameFromCode
