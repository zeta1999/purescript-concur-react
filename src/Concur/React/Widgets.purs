module Concur.React.Widgets where

import Prelude

import Concur.Core (Widget)
import Concur.React (HTML)
import Concur.React.DOM as D
import Concur.React.Props (ReactProps)
import Concur.React.Props as P
import Data.Maybe (Maybe(..))
import Effect.Class (liftEffect)
import Unsafe.Coerce (unsafeCoerce)

import Concur.Core.Dado as Da

-- | A Text input that returns its contents on enter
textInputEnter ::
  String ->
  Boolean ->
  (forall a. Array (ReactProps a)) ->
  Widget HTML String
textInputEnter val reset props = do
  e <- D.input $ props <> [P.onKeyEnter, P.defaultValue val]
  -- HACK: Using forced do notation, to force evaluation of the text input value in the same handler
  new <- pure $ P.unsafeTargetValue e
  when reset $ liftEffect (P.resetTargetValue "" e)
  pure new

-- | A Text input that has a button attached
-- | Returns its contents on the user pressing enter, or clicking the button
textInputWithButton ::
  String ->
  String ->
  (forall a. Array (ReactProps a)) ->
  (forall a. Array (ReactProps a)) ->
  Widget HTML String
textInputWithButton val buttonlabel inpProps buttonProps = do
  ref <- liftEffect P.createRef
  D.div_ Da.do
    D.input $ inpProps <>
      [ P.unsafeTargetValue <$> P.onKeyEnter
      , P.defaultValue val
      , P.refProp ref P.ref
      ]
    D.text " "
    do
      _ <- D.button (buttonProps <> [P.onClick]) $ D.text buttonlabel
      mInput <- liftEffect $ P.refNullableGetter ref
      case mInput of
        Nothing -> pure val
        Just inp -> pure (unsafeCoerce inp).value
