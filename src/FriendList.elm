module FriendList exposing (..)

import Navigation
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import PersonDetail exposing (Person)
import Strengths exposing (getStrengthNameListFromCodex)
import Json.Encode as JE
import Json.Decode as JD
import Material
import Material.List as Lists
import Material.Button as Button
import Material.Icon as Icon


-- model


type alias Model =
    { friends : List Person
    , selected : Maybe Int
    , nextId : Int
    , viewState : ViewState
    , mdl : Material.Model
    }


type ViewState
    = Expanded
    | Collapsed


type alias Flags =
    { friendList : Maybe String
    , viewState : Maybe String
    }


init : Flags -> ( Model, Cmd Msg )
init flags =
    let
        initFriends =
            case flags.friendList of
                Nothing ->
                    []

                Just json ->
                    decodeFriends json

        initNextId =
            List.length initFriends

        initModel =
            { friends = initFriends
            , selected = Nothing
            , nextId = initNextId
            , viewState = Expanded
            , mdl = Material.model
            }
    in
        ( initModel, Cmd.none )



-- update


type Msg
    = Create
    | Select Person
    | Save Person
    | Delete Person
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
                Ok list ->
                    List.indexedMap (,) list

                Err msg ->
                    []
    in
        List.map insertId indexedList


decodeFriend : JD.Decoder Person
decodeFriend =
    let
        asdf =
            JD.map2 makePerson (JD.field "n" JD.string) (JD.field "s" JD.string)
    in
        asdf


makePerson : String -> String -> Person
makePerson name maybeCodex =
    let
        codex =
            if maybeCodex == "" then
                Nothing
            else
                Just maybeCodex
    in
        { id = 0
        , name = name
        , strengths = codex
        }


insertId : ( Int, Person ) -> Person
insertId ( id, person ) =
    { person | id = id }



-- view


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
                , Button.render Mdl
                    [ person.id ]
                    model.mdl
                    [ Button.icon
                    , Button.onClick (Select person)
                    ]
                    [ Icon.i "create" ]
                ]


strengthsInfo : Person -> Html Msg
strengthsInfo person =
    Lists.subtitle []
        [ text
            (person.strengths
                |> getStrengthNameListFromCodex
                |> String.join ", "
            )
        ]



-- subscriptions


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none
