port module Main exposing (..)

import Navigation
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)

import Json.Encode as JE
import Json.Decode as JD

import Material
import Material.Scheme
import Material.Button as Button
import Material.Icon as Icon
import Material.Options exposing (css)
import Material.Layout as Layout
import Material.Menu as Menu

import FriendList exposing (ViewState(..))
import PersonDetail exposing (Person)



{-- MAIN --}


main : Program Flags Model Msg
main =
  Navigation.programWithFlags locationToMsg
    { init = init
    , update = update
    , view = view
    , subscriptions = subscriptions
    }


type alias Flags =
  { friendList : Maybe String
  , viewState : Maybe String
  }



{-- MODEL --}


type alias Model =
  { page : Page
  , list : FriendList.Model
  , detail : PersonDetail.Model
  , viewState : ViewState
  , mdl : Material.Model
  }


type Page
  = NotFound
  | FriendListPage
  | PersonDetailPage


init : Flags -> Navigation.Location -> ( Model, Cmd Msg )
init flags location =
  let
    ( friendListModel, friendListCmd ) =
      FriendList.init flags

    ( personDetailModel, personDetailCmd ) =
      PersonDetail.init 0

    viewState =
      case flags.viewState of
        Nothing -> Expanded
        Just json -> decodeViewState json

    initModel =
      { page = hashToPage location.hash
      , list = friendListModel
      , detail = personDetailModel
      , viewState = viewState
      , mdl = Material.model
      }

  in
    ( initModel
    , Cmd.batch
      [ Cmd.map FriendListMsg friendListCmd
      , Cmd.map PersonDetailMsg personDetailCmd
      ]
    )



-- UPDATE


type Msg
  = Navigate Page
  | ChangePage Page
  | Create
  | ToggleViewState
  | PersonDetailMsg PersonDetail.Msg
  | FriendListMsg FriendList.Msg
  | Mdl (Material.Msg Msg)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
  case msg of
    Navigate page ->
      ( model
      , Navigation.newUrl <| pageToHash page
      )

    ChangePage page ->
      ( { model | page = page }, Cmd.none )

    Create ->
      create model

    ToggleViewState ->
      let
        newViewState =
          case model.viewState of
            Collapsed -> Expanded
            Expanded -> Collapsed

        saveCmd =
          newViewState
            |> encodeViewState
            |> saveViewState
      in
        ( { model | viewState = newViewState }, saveCmd )

    FriendListMsg listMsg ->
      messageFromList listMsg model

    PersonDetailMsg personMsg ->
      messageFromPerson personMsg model

    Mdl msg_ ->
      Material.update msg_ model


create : Model -> ( Model, Cmd Msg )
create model =
  let
    ( newListModel, listCmd ) =
      FriendList.update FriendList.Create model.list

    ( newDetailModel, detailCmd ) =
      PersonDetail.init model.list.nextId
  in
    ( { model
      | list = newListModel
      , detail = newDetailModel
      }
    , Navigation.newUrl "#add"
    )


messageFromList : FriendList.Msg -> Model -> ( Model, Cmd Msg )
messageFromList msg model =
  let
    ( newListModel, cmd ) =
      FriendList.update msg model.list

    newDetailModel =
      updateDetailFromList msg model
  in
    ( { model
      | list = newListModel
      , detail = newDetailModel
      }
    , Cmd.map FriendListMsg cmd
    )


updateDetailFromList : FriendList.Msg -> Model -> PersonDetail.Model
updateDetailFromList msg model =
  case msg of
    FriendList.Select person ->
      let
        ( newDetailModel, cmd ) =
          PersonDetail.initWith person
      in
        newDetailModel

    _ ->
      model.detail


messageFromPerson : PersonDetail.Msg -> Model -> ( Model, Cmd Msg )
messageFromPerson msg model =
  let
    ( newDetailModel, cmd ) =
      PersonDetail.update msg model.detail

    newListModel =
      updateListFromPerson msg newDetailModel model

    saveCmd =
      if msg == PersonDetail.Save then
        newListModel
          |> encodeFriends
          |> saveFriendList
      else
        Cmd.none
  in
    ( { model
      | list = newListModel
      , detail = newDetailModel
      }
    , Cmd.batch
      [ Cmd.map PersonDetailMsg cmd
      , saveCmd
      ]
    )


updateListFromPerson : PersonDetail.Msg -> PersonDetail.Model -> Model -> FriendList.Model
updateListFromPerson msg detailModel model =
  case msg of
    PersonDetail.Save ->
      let
        ( newListModel, cmd ) =
          FriendList.update (FriendList.Save detailModel.person) model.list
      in
        newListModel

    PersonDetail.Delete ->
      let
        ( newListModel, cmd ) =
          FriendList.update (FriendList.Delete detailModel.person) model.list
      in
        newListModel

    _ ->
      model.list


encodeFriends : FriendList.Model -> JE.Value
encodeFriends model =
  model.friends
    |> List.map encodeFriend
    |> JE.list


encodeFriend : Person -> JE.Value
encodeFriend person =
  JE.object
    [ ( "n", JE.string person.name )
    , ( "s", JE.string (Maybe.withDefault "" person.strengths) )
    ]


decodeViewState : String -> ViewState
decodeViewState json =
  let
    jsonViewState =
      JD.decodeString JD.string json

    viewState =
      case jsonViewState of
        Ok string ->
          case string of
            "Expanded" -> Expanded
            "Collapsed" -> Collapsed
            _ -> Expanded

        Err msg ->
          Expanded
  in
    viewState


encodeViewState : ViewState -> JE.Value
encodeViewState viewState =
  case viewState of
    Expanded -> JE.string "Expanded"
    Collapsed -> JE.string "Collapsed"



{-- VIEW --}


type alias Mdl =
  Material.Model


(=>) : a -> b -> ( a, b )
(=>) =
  (,)


view : Model -> Html Msg
view model =
  let
    page =
      case model.page of
        FriendListPage ->
          Html.map FriendListMsg
            (FriendList.view model.list model.viewState)

        PersonDetailPage ->
          Html.map PersonDetailMsg
            (PersonDetail.view model.detail)

        NotFound ->
            div [ class "main" ]
              [ h1 []
                [ text "Page Not Found!" ]
              ]
  in
    div [ class "mdl-layout--no-drawer-button" ]
      [ Layout.render Mdl
        model.mdl
        [ Layout.fixedHeader ]
        { header = [ pageHeader model ]
        , drawer = []
        , tabs = ( [], [] )
        , main =
          [ page
          , addButton model
          ]
        }
      ]


pageHeader : Model -> Html Msg
pageHeader model =
  let
    label =
      case model.viewState of
        Collapsed -> "Show Strengths"
        Expanded -> "Hide Strengths"

    menu =
      case model.page of
        FriendListPage ->
          Menu.render Mdl [1] model.mdl
            [ Menu.ripple, Menu.bottomRight ]
            [ Menu.item
              [ Menu.onSelect ToggleViewState ]
              [ text label ]
            ]

        _ ->
          div [] []
  in
    Layout.row []
      [ Layout.title [] [ text "Strengths Friender" ]
      , Layout.spacer
      , menu
      ]


addButton : Model -> Html Msg
addButton model =
  case model.page of
    FriendListPage ->
      div
        [ style
          [ "position" => "absolute"
          , "right" => "0px"
          , "bottom" => "24px"
          ]
        ]
        [ Button.render Mdl [0] model.mdl
          [ Button.fab
          , Button.colored
          , Button.ripple
          , Button.onClick Create
          , css "margin" "0 24px"
          ]
          [ Icon.i "add" ]
        ]

    _ ->
      div [] []


viewToggle : Model -> Html Msg
viewToggle model =
  let
    buttonLabel =
      case model.viewState of
        Collapsed -> "Show Strengths"
        Expanded -> "Hide Strengths"
  in
    button [ onClick ToggleViewState ] [ text buttonLabel ]



{-- SUBSCRIPTIONS --}


subscriptions : Model -> Sub Msg
subscriptions model =
  let
    friendListSub =
      FriendList.subscriptions model.list

    personDetailSub =
      PersonDetail.subscriptions model.detail
  in
    Sub.batch
      [ Sub.map FriendListMsg friendListSub
      , Sub.map PersonDetailMsg personDetailSub
      ]


pageToHash : Page -> String
pageToHash page =
  case page of
    FriendListPage -> "/"
    PersonDetailPage -> "/#add"
    NotFound -> "/#"


hashToPage : String -> Page
hashToPage hash =
  case hash of
    "" -> FriendListPage
    "#add" -> PersonDetailPage
    _ -> NotFound


locationToMsg : Navigation.Location -> Msg
locationToMsg location =
  location.hash
    |> hashToPage
    |> ChangePage


port saveFriendList : JE.Value -> Cmd msg
port saveViewState : JE.Value -> Cmd msg
