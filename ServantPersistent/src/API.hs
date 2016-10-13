{-# LANGUAGE DataKinds       #-}
{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE TypeOperators   #-}
{-# LANGUAGE RecordWildCards #-}
{-# LANGUAGE TypeFamilies #-}
module API
    where

import Data.Aeson
import Data.Aeson.TH
import Network.Wai
import Network.Wai.Handler.Warp
import Servant
import Data.ByteString
import Data.Proxy
import Control.Monad.Except
import Control.Monad.Reader
import Servant.Server.Experimental.Auth.Cookie
import Auth
import Types

type TenantID = Int
type ProductID = Int
type Tenant = ()
type ActivationRequest = ()
type ActivationResponse = ()
type Product = ()

type TenantAPI = 
      ReqBody '[JSON] Tenant :> Post '[JSON] (Headers '[Header "location" String] Tenant)
 :<|> Capture "id" TenantID  :> Get '[JSON] Tenant
 :<|> Capture "id" TenantID  :> "activate" :> ReqBody '[JSON] ActivationRequest :> Post '[JSON] ActivationResponse

type SessionAPI = 
      "new" :> ReqBody '[JSON] LoginForm :> Post '[JSON] (Headers '[Header "set-cookie" ByteString] ())
-- :<|> "refresh" :> ReqBody '[JSON] LoginForm :> Post '[JSON] (Headers '[Header "set-cookie" ByteString] ())
-- :<|> "destroy" :> ReqBody '[JSON] LoginForm :> Post '[JSON] (Headers '[Header "set-cookie" ByteString] ())

type ProductAPI = 
      Capture "id" ProductID :> Get '[JSON] Product
 :<|> Get '[JSON] [Product]

type API = "tenants"  :> TenantAPI
      :<|> "session"  :> SessionAPI
      :<|> "products" :> AppAuth :> ProductAPI

api :: Proxy API
api = Proxy
