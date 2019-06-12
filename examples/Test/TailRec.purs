module Test.TailRec where

import Prelude

import Concur.Core (Widget)
import Concur.React (HTML)
import Concur.React.DOM as D
import Concur.React.Props as P
import Effect.Aff (Milliseconds(..), delay)
import Effect.Aff.Class (liftAff)

import Concur.Core.Dado as Da

tailRecDemo :: forall a. Widget HTML a
tailRecDemo = D.div_ Da.do
  D.p_ $ D.text $ "This demo shows that tail recursion is stack safe in Concur (even without using tailRecM)."
  D.p_ $ D.text "This widget performs a tail recursive call roughly once every 10 milliseconds, and will never exhaust the stack."
  do
    void $ D.button [P.onClick] $ D.text "Start Tail Recursion Demo"
    tailRecWidget 0 2

tailRecWidget :: forall a. Int -> Int -> Widget HTML a
tailRecWidget count times = do
  stopRequested <- D.div_ Da.do
    D.text $ "Recursive call # " <> show count <> " "
    true <$ do D.button [P.onClick] $ D.text $ "Stop it!"
    false <$ do liftAff (delay (Milliseconds 10.0))
  if stopRequested
    then do
      D.div_ Da.do
        D.text ("Ran " <> show count <> " recursive calls. ")
        D.button [unit <$ P.onClick] $ D.text "Restart"
        D.text (" (iteration # " <> show times <> ")?")
      tailRecWidget 0 (times + 1)
    else tailRecWidget (count+1) times
