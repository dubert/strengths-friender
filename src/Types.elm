module Types exposing (..)


type alias Person =
  { id : Int
  , name : String
  , strengths : Maybe String
  }


type alias Flags =
  { friendList : Maybe String
  , viewState : Maybe String
  }


type ViewState
  = Expanded
  | Collapsed
