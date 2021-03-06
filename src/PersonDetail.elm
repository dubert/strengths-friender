module PersonDetail exposing (..)

import Navigation
import Html exposing (..)
import Html.Events exposing (..)
import Html.Attributes exposing (..)

import Dict exposing (Dict)

import Material
import Material.Textfield as Textfield
import Material.Options as Options
import Material.Button as Button

import Types exposing (Person)
import StrengthField



{-- MODEL --}


type alias Model =
  { person : Person
  , strengthInputs : Dict InputId StrengthField.Model
  , mdl : Material.Model
  }


type alias InputId = Int


init : Int -> ( Model, Cmd Msg )
init currentId =
  let
    ( fieldModel, cmd ) =
      StrengthField.init

    initInputs =
      Dict.fromList
        (List.indexedMap (,) (List.repeat 5 fieldModel))
  in
    ( { person = initPerson currentId
      , strengthInputs = initInputs
      , mdl = Material.model
      }
    , Cmd.none
    )


initPerson : Int -> Person
initPerson currentId =
  { id = currentId
  , name = ""
  , strengths = Nothing
  }


initWith : Person -> ( Model, Cmd Msg )
initWith person =
  ( { person = person
    , strengthInputs = injectAllStrengths person.strengths
    , mdl = Material.model
    }
  , Cmd.none
  )



-- UPDATE


type Msg
  = NameInput String
  | StrengthFieldMsg InputId StrengthField.Msg
  | Delete
  | Save
  | Mdl (Material.Msg Msg)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
  case msg of
    NameInput name ->
      model
        |> setNameInput name

    StrengthFieldMsg index inputMsg ->
      model
        |> handleInputMsg index inputMsg

    Delete ->
      ( model, Navigation.newUrl "/" )

    Save ->
      model
        |> save

    Mdl msg_ ->
      Material.update Mdl msg_ model


setNameInput : String -> Model -> ( Model, Cmd Msg )
setNameInput name ({ person } as model) =
  ( { model
    | person = { person | name = name }
    }
  , Cmd.none
  )


handleInputMsg : InputId -> StrengthField.Msg -> Model -> ( Model, Cmd Msg )
handleInputMsg inputId msgStrengthField model =
  case Dict.get inputId model.strengthInputs of
    Nothing ->
      ( model, Cmd.none )

    Just strength ->
      let
        ( newFieldModel, cmd ) =
          StrengthField.update msgStrengthField strength

        newStrengths =
          Dict.insert inputId newFieldModel model.strengthInputs
      in
        ( { model | strengthInputs = newStrengths }, Cmd.none )


save : Model -> ( Model, Cmd Msg )
save model =
  let
    newFieldModels =
      validateAllFields model

    newStrengthsCode =
      extractAllCodes newFieldModels

    person = model.person
    newPerson = { person | strengths = newStrengthsCode }

    cmds =
      if isAllFieldsValid newFieldModels then
        Navigation.newUrl "/"
      else
        Cmd.none
  in
    ( { model
      | person = newPerson
      , strengthInputs = newFieldModels
      }
    , cmds
    )


validateAllFields : Model -> Dict Int StrengthField.Model
validateAllFields model =
  let
    validateFieldModel strength =
      let
        ( fieldModel, cmd ) =
          StrengthField.update StrengthField.Validate strength
      in
        fieldModel
  in
    Dict.map
      (\_ strength -> validateFieldModel strength)
      model.strengthInputs


isAllFieldsValid : Dict Int StrengthField.Model -> Bool
isAllFieldsValid fields =
  fields
    |> Dict.toList
    |> List.all isFieldValid


isFieldValid : ( Int, StrengthField.Model ) -> Bool
isFieldValid ( id, model ) =
  model.validation
    |> Tuple.first


extractAllCodes : Dict Int StrengthField.Model -> Maybe String
extractAllCodes fields =
  if isAllFieldsValid fields
    then Just (getCodes fields)
    else Nothing


getCodes : Dict Int StrengthField.Model -> String
getCodes fields =
  let
    extractCode strength =
      strength.validation
        |> Tuple.second
        |> Maybe.withDefault ""

    calculate index strength result =
      result ++ (extractCode strength)
  in
    Dict.foldl calculate "" fields


injectAllStrengths : Maybe String -> Dict Int StrengthField.Model
injectAllStrengths strengthCode =
  case strengthCode of
    Nothing ->
      let
        ( fieldModel, cmd ) =
          StrengthField.init
      in
        Dict.fromList
          (List.indexedMap (,) (List.repeat 5 fieldModel))

    Just code ->
      let
        index =
          List.range 0 4

        codes =
          code
            |> String.toList
            |> List.map injectStrength

        indexWithCodes =
          List.map2 (,) index codes
      in
        Dict.fromList indexWithCodes


injectStrength : Char -> StrengthField.Model
injectStrength code =
  let
    ( fieldModel, cmd ) =
      StrengthField.initWith code
  in
    fieldModel



{-- VIEW --}


(=>) : a -> b -> ( a, b )
(=>) =
  (,)


view : Model -> Html Msg
view model =
  Html.form
    [ style [ "padding" => "20px" ]
    , onSubmit Save
    ]
    ( [ div []
      [ Textfield.render Mdl [0] model.mdl
        [ Textfield.label "Name"
        , Textfield.floatingLabel
        , Options.onInput NameInput
        , Textfield.value <| model.person.name
        , Textfield.autofocus
        , Options.css "width" "100%"
        ] []
      ]
      ]
    ++
      (model.strengthInputs |> Dict.toList |> List.map wrappedField)
    ++
      [ div
        [ style
          [ "display" => "flex"
          , "justify-content" => "space-between"
          ]
        ]
        [ Button.render Mdl [0] model.mdl
          [ Button.raised
          , Button.ripple
          , Options.onClick Delete
          ]
          [ text "Delete" ]
        , Button.render Mdl [1] model.mdl
          [ Button.raised
          , Button.colored
          , Button.ripple
          , Button.type_ "submit"
          ]
          [ text "Save" ]
        ]
      ]
    )


wrappedField : ( Int, StrengthField.Model ) -> Html Msg
wrappedField ( id, model ) =
  let
    ordinal =
      getOrdinalNumber id
  in
    Html.map (StrengthFieldMsg id) <| StrengthField.view model ordinal


getOrdinalNumber : Int -> String
getOrdinalNumber number =
  case number of
    0 ->"First"
    1 ->"Second"
    2 ->"Third"
    3 ->"Fourth"
    4 ->"Fifth"
    _ ->""



{-- SUBSCRIPTIONS --}


subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.none
