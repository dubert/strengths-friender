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
import Material.Snackbar as Snackbar
import Material.Options exposing (css)
import Material.Helpers exposing (map1st, map2nd)
import Material.Layout as Layout
import Material.Menu as Menu

import Types exposing (Person, Flags, ViewState(..))
import FriendList
import PersonDetail



{-- MAIN --}


main : Program Flags Model Msg
main =
  Navigation.programWithFlags locationToMsg
    { init = init
    , update = update
    , view = view
    , subscriptions = subscriptions
    }



{-- MODEL --}


type alias Model =
  { page : Page
  , list : FriendList.Model
  , detail : PersonDetail.Model
  , viewState : ViewState
  , snackbar : SnackbarModel
  , mdl : Material.Model
  }


type alias SnackbarModel =
  Snackbar.Model Person


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
      , snackbar = Snackbar.model
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
  | Snackbar (Snackbar.Msg Person)
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
      model
        |> createNewPerson

    ToggleViewState ->
      model
        |> setViewState

    FriendListMsg listMsg ->
      model
        |> handleListMsg listMsg

    PersonDetailMsg detailMsg ->
      model
        |> handleDetailMsg detailMsg

    Snackbar (Snackbar.Click person) ->
      model
        |> undoDelete person

    Snackbar msg_ ->
      Snackbar.update msg_ model.snackbar
        |> map1st (\s -> { model | snackbar = s })
        |> map2nd (Cmd.map Snackbar)

    Mdl msg_ ->
      Material.update msg_ model


createNewPerson : Model -> ( Model, Cmd Msg )
createNewPerson model =
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


setViewState : Model -> ( Model, Cmd Msg )
setViewState model =
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


handleListMsg : FriendList.Msg -> Model -> ( Model, Cmd Msg )
handleListMsg msgFriendList model =
  let
    ( newListModel, cmd ) =
      FriendList.update msgFriendList model.list

    newDetailModel =
      updateDetailFromList msgFriendList model
  in
    ( { model
      | list = newListModel
      , detail = newDetailModel
      }
    , Cmd.map FriendListMsg cmd
    )


updateDetailFromList : FriendList.Msg -> Model -> PersonDetail.Model
updateDetailFromList msgFriendList model =
  case msgFriendList of
    FriendList.Select person ->
      let
        ( newDetailModel, cmd ) =
          PersonDetail.initWith person
      in
        newDetailModel

    _ ->
      model.detail


handleDetailMsg : PersonDetail.Msg -> Model -> ( Model, Cmd Msg )
handleDetailMsg msgPersonDetail model =
  let
    ( newDetailModel, cmd ) =
      PersonDetail.update msgPersonDetail model.detail

    newListModel =
      updateListFromPerson msgPersonDetail newDetailModel model

    -- TOOD: I want to map the save command better instead of using an if/or
    saveCmd =
      if msgPersonDetail == PersonDetail.Save
      || msgPersonDetail == PersonDetail.Delete
        then
          newListModel
            |> encodeFriends
            |> saveFriendList
        else
          Cmd.none

    ( newSnackbarModel, snackbarCmd ) =
      issueSnackbar msgPersonDetail newDetailModel.person model

  in
    ( { model
      | list = newListModel
      , detail = newDetailModel
      , snackbar = newSnackbarModel
      }
    , Cmd.batch
      [ Cmd.map PersonDetailMsg cmd
      , saveCmd
      , snackbarCmd
      ]
    )


updateListFromPerson : PersonDetail.Msg -> PersonDetail.Model -> Model -> FriendList.Model
updateListFromPerson msgPersonDetail detailModel model =
  case msgPersonDetail of
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


issueSnackbar : PersonDetail.Msg -> Person -> Model -> ( SnackbarModel, Cmd Msg )
issueSnackbar msgPersonDetail person model =
  if msgPersonDetail == PersonDetail.Delete then
    let
      text =
        person.name ++ " successfully deleted"

      toast =
        Snackbar.snackbar person text "UNDO"

      ( snackbarModel, snackbarCmd ) =
        Snackbar.add toast model.snackbar
          |> map2nd (Cmd.map Snackbar)

    in
      ( snackbarModel, snackbarCmd )
  else
    ( model.snackbar, Cmd.none )


undoDelete : Person -> Model -> ( Model, Cmd Msg )
undoDelete person model =
  let
    ( newListModel, listCmd ) =
      FriendList.update (FriendList.Undo person) model.list

    saveCmd =
      newListModel
        |> encodeFriends
        |> saveFriendList
  in
    ( { model | list = newListModel }, saveCmd )


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
      [ Layout.render Mdl model.mdl
        [ Layout.fixedHeader ]
        { header = [ pageHeader model ]
        , drawer = []
        , tabs = ( [], [] )
        , main =
          [ page
          , addButton model
          , Snackbar.view model.snackbar |> Html.map Snackbar
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
          [ "position" => "fixed"
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
