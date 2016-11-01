{-# LANGUAGE DeriveGeneric      #-}
{-# LANGUAGE DeriveAnyClass     #-}
{-# LANGUAGE TypeFamilies       #-}
{-# LANGUAGE DataKinds          #-}
{-# LANGUAGE TemplateHaskell    #-}
{-# LANGUAGE FlexibleInstances  #-}
{-# LANGUAGE FlexibleContexts   #-}
module DBTypes where

import Data.Aeson
import Data.Aeson.TH
import Data.Text

import Data.Time.Clock
import GHC.Generics
import Control.Lens
import Types
import Models
import Data.Default
import Database.Persist


type TenantID = Key DBTenant
type Tenant = DBTenant
type TenantOutput = DBTenant
type UserID = Key DBUser
type ProductID = Key DBProduct

data Product = Product { getProduct :: Entity DBProduct
                       , getVariants :: [Entity DBVariant]}
-- Dummy instance

instance ToJSON Product where
  toJSON = undefined
data ProductInput = PIn {}

data DBError = TenantNotFound TenantID
             | UserNotFound UserID 
             | ProductNotFound ProductID
             | ViolatesTenantUniqueness (Unique Tenant)
                deriving (Eq, Show)

data UserCreationError = UserExists Text
                       | TenantDoesn'tExist Text
                        deriving (Eq, Show)
data ActivationError = ActivationError

data Role = Role { roleName :: Text
                 , roleCapabilities :: [Capability]
                 }

instance Default Role where
    def = Role "Default Role" []

data Capability = ViewUserDetails
                | EditUserDetails
                | EditUserRoles
                | EditTenantDetails

data Activation =
    Activation { activationTenantID :: TenantID
               , activationTime :: UTCTime
               } deriving (Generic)

data TenantIdent =
    TenantI { _name :: Text
            , _backofficeDomain :: Text
            } deriving (Generic)
instance FromJSON TenantIdent where
    parseJSON = genericParseJSON (defaultOptions { fieldLabelModifier = Prelude.drop 1})
instance ToJSON TenantIdent where
    toEncoding = genericToEncoding (defaultOptions { fieldLabelModifier = Prelude.drop 1})
    toJSON = genericToJSON (defaultOptions { fieldLabelModifier = Prelude.drop 1})

instance HasName TenantIdent where
    name = lens _name (\ti n -> ti { _name = n } )
instance HasBackofficeDomain TenantIdent where
    backofficeDomain = lens _backofficeDomain (\ti bd -> ti { _backofficeDomain = bd } )

type TenantInput = TenantIdent

data FieldStatus = Present | Absent | Unknown

type family Omittable (state :: FieldStatus) a where
    Omittable Present a = a
    Omittable Absent a = ()
    Omittable Unknown a = Maybe a

class HasTenantID s where
    tenantID :: Lens' s TenantID

class HasUserID s where
    userID :: Lens' s UserID

instance HasTenantID DBUser where
    tenantID = dBUserTenantID

data UserBase (pass :: FieldStatus) (st :: FieldStatus) (rl :: FieldStatus) (id :: FieldStatus) =
    UserB { _userFirstName :: Text
          , _userLastName :: Text
          , _userEmail :: Text
          , _userPhone :: Text
          , _userUsername :: Text
          , _userTenantID :: TenantID
          , _userPassword :: Omittable pass Text
          , _userStatus :: Omittable st UserStatus
          , _userRole :: Omittable rl Role
          , _userUserID :: Omittable id UserID
          } deriving (Generic)

makeLenses ''UserBase

instance HasHumanName (UserBase pass st rl id) where
    firstName = userFirstName
    lastName = userLastName
instance HasContactDetails (UserBase pass st rl id) where
    email = userEmail
    phone = userPhone
instance HasUsername (UserBase pass st rl id) where
    username = userUsername
instance HasPassword (UserBase Present st rl id) where
    password = userPassword
instance HasTenantID (UserBase pas st rl id) where
    tenantID = userTenantID
instance HasUserID (UserBase pas st rl Present) where
    userID = userUserID

deriving instance (Show (Omittable pass Text),
                   Show (Omittable st UserStatus),
                   Show (Omittable rl Role),
                   Show (Omittable id UserID))
                   => Show (UserBase pass st rl id)

type UserInput = UserBase Present Absent Absent Absent
type User = UserBase Absent Present Present Present

