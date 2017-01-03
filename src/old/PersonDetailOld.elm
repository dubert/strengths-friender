-- module PersonDetail exposing (..)


module Main exposing (..)

import Html exposing (..)
import Html.Events exposing (..)
import Html.Attributes exposing (..)
import Strengths


-- main


main : Program Never Model Msg
main =
    Html.program
        { init = init
        , update = update
        , view = view
        , subscriptions = subscriptions
        }



-- model


type alias Model =
    { id : String
    , name : String
    , strengths : List Char
    , strength1 : String
    , strength2 : String
    , strength3 : String
    , strength4 : String
    , strength5 : String
    , error1 : Status
    , error2 : Status
    , error3 : Status
    , error4 : Status
    , error5 : Status
    }


type alias Status =
    ( Bool, Maybe String )


emptyStatus : Status
emptyStatus =
    ( False
    , Nothing
    )


initModel : Model
initModel =
    { id = ""
    , name = ""
    , strengths = []
    , strength1 = ""
    , strength2 = ""
    , strength3 = ""
    , strength4 = ""
    , strength5 = ""
    , error1 = emptyStatus
    , error2 = emptyStatus
    , error3 = emptyStatus
    , error4 = emptyStatus
    , error5 = emptyStatus
    }


init : ( Model, Cmd Msg )
init =
    ( initModel, Cmd.none )



-- update


type Msg
    = NameInput String
    | StrengthsInput Field String
    | Delete
    | Save


type Field
    = First
    | Second
    | Third
    | Fourth
    | Fifth


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NameInput name ->
            ( { model | name = name }, Cmd.none )

        StrengthsInput field text ->
            edit model field text

        Delete ->
            ( model, Cmd.none )

        Save ->
            model
                |> publishErrors
                |> validateStrengths


edit : Model -> Field -> String -> ( Model, Cmd Msg )
edit model field text =
    case field of
        First ->
            ( { model
                | strength1 = text
                , error1 = checkInputValidity text
              }
            , Cmd.none
            )

        Second ->
            ( { model
                | strength2 = text
                , error2 = checkInputValidity text
              }
            , Cmd.none
            )

        Third ->
            ( { model
                | strength3 = text
                , error3 = checkInputValidity text
              }
            , Cmd.none
            )

        Fourth ->
            ( { model
                | strength4 = text
                , error4 = checkInputValidity text
              }
            , Cmd.none
            )

        Fifth ->
            ( { model
                | strength5 = text
                , error5 = checkInputValidity text
              }
            , Cmd.none
            )



-- newEdit : Model -> Int -> String -> ( Model, Cmd Msg )
-- newEdit model int text =


checkInputValidity : String -> Status
checkInputValidity text =
    let
        result =
            Strengths.isValidStrength text
    in
        case result of
            Err msg ->
                ( False, Nothing )

            Ok strength ->
                ( True, Nothing )


checkInputForErrors : String -> Status
checkInputForErrors text =
    let
        result =
            Strengths.isValidStrength text
    in
        case result of
            Err msg ->
                ( False, Just msg )

            Ok strength ->
                ( True, Nothing )


publishErrors : Model -> Model
publishErrors model =
    let
        errorStatus1 =
            checkInputForErrors model.strength1

        errorStatus2 =
            checkInputForErrors model.strength2

        errorStatus3 =
            checkInputForErrors model.strength3

        errorStatus4 =
            checkInputForErrors model.strength4

        errorStatus5 =
            checkInputForErrors model.strength5
    in
        { model
            | error1 = errorStatus1
            , error2 = errorStatus2
            , error3 = errorStatus3
            , error4 = errorStatus4
            , error5 = errorStatus5
        }


validateStrengths : Model -> ( Model, Cmd Msg )
validateStrengths model =
    ( model, Cmd.none )



-- view


view : Model -> Html Msg
view model =
    div [ class "main" ]
        [ headerSection model
        , detailSection model
        ]


headerSection : Model -> Html Msg
headerSection model =
    Html.header []
        [ h1 [] [ text "Editing Friend" ]
        ]


detailSection : Model -> Html Msg
detailSection model =
    Html.form [ class "add-friend", onSubmit Save ]
        [ fieldset []
            [ legend [] [ text "Add / Edit Friend" ]
            , div []
                [ label [] [ text "Name" ]
                , input
                    [ type_ "text"
                    , value model.name
                    , onInput NameInput
                    ]
                    []
                ]
            , div []
                [ label [] [ text "First Strength" ]
                , input
                    [ type_ "text"
                    , value model.strength1
                    , onInput (StrengthsInput First)
                    ]
                    []
                , span [] [ text <| Maybe.withDefault "" (Tuple.second model.error1) ]
                ]
            , div []
                [ label [] [ text "Second Strength" ]
                , input
                    [ type_ "text"
                    , value model.strength2
                    , onInput (StrengthsInput Second)
                    ]
                    []
                , span [] [ text <| Maybe.withDefault "" (Tuple.second model.error2) ]
                ]
            , div []
                [ label [] [ text "Third Strength" ]
                , input
                    [ type_ "text"
                    , value model.strength3
                    , onInput (StrengthsInput Third)
                    ]
                    []
                , span [] [ text <| Maybe.withDefault "" (Tuple.second model.error3) ]
                ]
            , div []
                [ label [] [ text "Fourth Strength" ]
                , input
                    [ type_ "text"
                    , value model.strength4
                    , onInput (StrengthsInput Fourth)
                    ]
                    []
                , span [] [ text <| Maybe.withDefault "" (Tuple.second model.error4) ]
                ]
            , div []
                [ label [] [ text "Fifth Strength" ]
                , input
                    [ type_ "text"
                    , value model.strength5
                    , onInput (StrengthsInput Fifth)
                    ]
                    []
                , span [] [ text <| Maybe.withDefault "" (Tuple.second model.error5) ]
                ]
            , div []
                [ label [] []
                , button [ type_ "submit" ] [ text "Save" ]
                ]
            ]
        ]



-- subscriptions


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none
