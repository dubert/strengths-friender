module StrengthField exposing (..)

import Html exposing (..)
import Html.Events exposing (..)
import Html.Attributes exposing (..)
import Strengths
import Material
import Material.Textfield as Textfield
import Material.Options as Options


-- model


type alias Model =
    { field : String
    , validation : Status
    , mdl : Material.Model
    }


type alias Status =
    ( Bool, Maybe String )


init : ( Model, Cmd Msg )
init =
    ( { field = ""
      , validation = ( False, Nothing )
      , mdl = Material.model
      }
    , Cmd.none
    )


initWith : Char -> ( Model, Cmd Msg )
initWith code =
    let
        strengthResult =
            Strengths.getStrengthFromCode code
    in
        case strengthResult of
            Ok strength ->
                ( { field = strength.name
                  , validation = ( True, Just (toString code) )
                  , mdl = Material.model
                  }
                , Cmd.none
                )

            Err msg ->
                init



-- update


type Msg
    = Input String
    | Validate
    | Mdl (Material.Msg Msg)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Input text ->
            ( { model
                | field = text
                , validation = isInputValid text
              }
            , Cmd.none
            )

        Validate ->
            publishError model

        Mdl msg_ ->
            Material.update msg_ model


isInputValid : String -> Status
isInputValid text =
    let
        result =
            Strengths.isStrengthValid text
    in
        case result of
            Err msg ->
                ( False, Nothing )

            Ok strength ->
                ( True, Nothing )


publishError : Model -> ( Model, Cmd Msg )
publishError model =
    let
        result =
            Strengths.getStrengthFromName model.field
    in
        case result of
            Err msg ->
                ( { model
                    | validation = ( False, Just msg )
                  }
                , Cmd.none
                )

            Ok strength ->
                ( { model
                    | validation = ( True, Just (String.fromChar strength.id) )
                  }
                , Cmd.none
                )



-- view


view : Model -> String -> Html Msg
view model ordinal =
    let
        error =
            case (Tuple.second model.validation) of
                Just validation ->
                    Textfield.error <| validation

                Nothing ->
                    Options.nop
    in
        Textfield.render Mdl
            [ 0 ]
            model.mdl
            [ Textfield.label (ordinal ++ " Strength")
            , Textfield.floatingLabel
            , Textfield.onInput Input
            , Textfield.value <| model.field
            , if not (Tuple.first model.validation) then
                error
              else
                Options.nop
            , Options.css "width" "100%"
            ]
