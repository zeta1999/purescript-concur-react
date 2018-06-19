module Test.Ajax where

import Prelude

import Concur.Core (Widget)
import Concur.React (HTML)
import Concur.React.DOM (button, div', h4', p', text)
import Concur.React.Props (onClick)
import Control.Alt ((<|>))
import Effect.Aff.Class (liftAff)
import Effect.Class (liftEffect)
import Effect.Console (log)
import Data.Argonaut.Core (Json)
import Data.Argonaut.Decode (class DecodeJson, decodeJson, (.?))
import Data.Array (take)
import Data.Either (Either(..))
import Data.Traversable (traverse)
import Network.HTTP.Affjax (get)
import Network.HTTP.Affjax.Response as Response

-- Fetches posts from reddit json
newtype Post = Post
  { id :: String
  , title :: String
  }

type PostArray = Array Post

decodePostArray :: Json -> Either String PostArray
decodePostArray json = decodeJson json >>= traverse decodeJson

instance decodeJsonPost :: DecodeJson Post where
  decodeJson json = do
    obj <- decodeJson json
    d <- obj .? "data"
    id <- d .? "id"
    title <- d .? "title"
    pure (Post { id, title })

subreddits :: Array String
subreddits = ["programming", "purescript", "haskell", "javascript"]

ajaxWidget :: forall a. Widget HTML a
ajaxWidget = div'
  [ p' [text "Click button to fetch posts from reddit"]
  , div' (map fetchReddit subreddits)
  ]

fetchReddit :: forall a. String -> Widget HTML a
fetchReddit sub = div'
  [ h4' [text ("/r/" <> sub)]
  , showPosts
  ]
  where
    showPosts = button [onClick] [text "Fetch posts"] >>= \_ -> fetchPosts
    fetchPosts = do
      liftEffect (log ("Fetching posts from subreddit - " <> sub))
      resp <- (liftAff (get Response.json ("https://www.reddit.com/r/" <> sub <> ".json"))) <|> (text "Loading...")
      let postsResp = do
            o <- decodeJson resp.response
            d1 <- o .? "data"
            cs <- d1 .? "children"
            decodePostArray cs
      case postsResp of
        Left err -> text ("Error: " <> err)
        Right posts -> do
          div'
            [ div' (map (\(Post p) -> div' [text p.title]) (take 5 posts))
            , div' [button [unit <$ onClick] [text "Refresh"]]
            ]
          fetchPosts
