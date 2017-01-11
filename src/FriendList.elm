module FriendList exposing (..)

import Navigation
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)

import Json.Encode as JE
import Json.Decode as JD

import Material
import Material.List as Lists
import Material.Button as Button
import Material.Icon as Icon

import Types exposing (Person, Flags, ViewState(..))
import Strengths exposing (getStrengthNameListFromCodex)



{-- MODEL --}


type alias Model =
  { friends : List Person
  , selected : Maybe Int
  , nextId : Int
  , viewState : ViewState
  , mdl : Material.Model
  }


init : Flags -> ( Model, Cmd Msg )
init flags =
  let
    initFriends =
      case flags.friendList of
        Nothing -> []
        Just json -> decodeFriends json

    initModel =
      { friends = initFriends
      , selected = Nothing
      , nextId = List.length initFriends
      , viewState = Expanded
      , mdl = Material.model
      }
  in
    ( initModel, Cmd.none )



-- UPDATE


type Msg
  = Create
  | Select Person
  | Save Person
  | Delete Person
  | Undo Person
  | Mdl (Material.Msg Msg)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
  case msg of
    Create ->
      create model

    Select person ->
      ( { model
        | selected = Just person.id
        }
      , Navigation.newUrl "#add"
      )

    Save person ->
      let
        newFriends =
          List.map
            (\friend ->
              if friend.id == person.id then
                { friend
                  | name = person.name
                  , strengths = person.strengths
                }
              else
                friend
            )
            model.friends
      in
        ( { model
          | friends = newFriends
          , selected = Nothing
          }
        , Cmd.none
        )

    Delete person ->
      let
        newFriends =
          List.filter (\f -> f.id /= person.id) model.friends
      in
        ( { model
          | friends = newFriends
          , selected = Nothing
          }
        , Cmd.none
        )

    Undo person ->
      let
        newFriends =
          person :: model.friends
      in
        ( { model
          | friends = newFriends
          , selected = Nothing
          }
        , Cmd.none
        )

    Mdl msg_ ->
      Material.update msg_ model


create : Model -> ( Model, Cmd Msg )
create model =
  let
    newPerson =
      Person model.nextId "" Nothing

    newId =
      model.nextId + 1

    newFriends =
      newPerson :: model.friends
  in
    ( { model
      | friends = newFriends
      , selected = Just model.nextId
      , nextId = newId
      }
    , Navigation.newUrl "#add"
    )


decodeFriends : String -> List Person
decodeFriends json =
  let
    jsonList =
      JD.decodeString (JD.list decodeFriend) json

    indexedList =
      case jsonList of
        Ok list -> List.indexedMap (,) list
        Err msg -> []
  in
    List.map insertId indexedList


decodeFriend : JD.Decoder Person
decodeFriend =
  JD.map2 makePerson (JD.field "n" JD.string) (JD.field "s" JD.string)


makePerson : String -> String -> Person
makePerson name maybeCodex =
  let
    codex =
      if maybeCodex == ""
        then Nothing
        else Just maybeCodex
  in
    { id = 0
    , name = name
    , strengths = codex
    }


insertId : ( Int, Person ) -> Person
insertId ( id, person ) =
  { person | id = id }



{-- VIEW --}


(=>) : a -> b -> ( a, b )
(=>) =
  (,)


view : Model -> ViewState -> Html Msg
view model viewState =
  model.friends
    |> List.sortBy .name
    |> List.map (personView viewState model)
    |> Lists.ul []


personView : ViewState -> Model -> Person -> Html Msg
personView viewState model person =
  case viewState of
    Collapsed ->
      Lists.li []
        [ Lists.content [] [ text person.name ]
        , Button.render Mdl
          [ person.id ]
          model.mdl
          [ Button.icon
          , Button.onClick (Select person)
          ]
          [ Icon.i "create" ]
        ]

    Expanded ->
      Lists.li [ Lists.withSubtitle ]
        [ Lists.content []
          [ text person.name
          , strengthsInfo person
          ]
        , Button.render Mdl [person.id] model.mdl
          [ Button.icon
          , Button.onClick (Select person)
          ]
          [ Icon.i "create" ]
        ]


strengthsInfo : Person -> Html Msg
strengthsInfo person =
  let
    listOfStrengths =
      person.strengths
        |> getStrengthNameListFromCodex
        |> String.join ", "
  in
    Lists.subtitle [] [ text listOfStrengths ]



{-- SUBSCRIPTIONS --}


subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.none
