if SERVER then

   AddCSLuaFile("shared.lua")
   
end

SWEP.PrintName				= "Luca's BigSteel" 
SWEP.Author					= "i hate anime & seppdroid" 
SWEP.Instructions			= "Right click to fire bullet and Left click to fire a jumpbullet"
SWEP.Category 				= "Weapons"
SWEP.Base 					= "weapon_base"
SWEP.Slot 					= 1
SWEP.Spawnable 				= true
SWEP.AdminSpawnable 		= true
SWEP.AdminOnly 				= false

SWEP.ViewModelFOV 			= 70
SWEP.ViewModelFlip			= false
SWEP.ViewModel 				= "models/weapons/v_bigsteel.mdl"
SWEP.WorldModel 			= "models/weapons/w_bigsteel.mdl"
SWEP.UseHands 				= true
SWEP.Weight 				= 5
SWEP.AutoSwitchTo 			= false
SWEP.AutoSwitchFrom 		= false
SWEP.Primary.Sound 			= Sound("Weapon_357.Single")
SWEP.Primary.Recoil 		= 3
SWEP.Primary.Damage 		= 50
SWEP.Primary.NumShots 		= 1
SWEP.Primary.Cone 			= 0.01
SWEP.Primary.ClipSize 		= 6
SWEP.Primary.Delay 			= 0.5
SWEP.Primary.DefaultClip 	= 12
SWEP.Primary.Automatic 		= false
SWEP.Primary.Ammo 			= "357"
SWEP.Secondary.ClipSize 	= -1
SWEP.Secondary.DefaultClip 	= -1
SWEP.Secondary.Automatic 	= false
SWEP.Secondary.Ammo 		= "none"
SWEP.ExplosionRadius 		= 450
SWEP.ExplosionDamage 		= 25

function SWEP:Initialize()

   self:SetHoldType("pistol")
   
end

function SWEP:PrimaryAttack()

   if !self:CanPrimaryAttack() then return end
   
   local bullet = {}
   bullet.Num = self.Primary.NumShots
   bullet.Src = self.Owner:GetShootPos()
   bullet.Dir = self.Owner:GetAimVector()
   bullet.Spread = Vector(self.Primary.Cone, self.Primary.Cone, 0)
   bullet.Tracer = 1
   bullet.TracerName = "Tracer"
   bullet.Force = 5
   bullet.Damage = self.Primary.Damage
   
   self:ShootEffects()
   
   self.Owner:FireBullets(bullet)
   
   self:EmitSound(self.Primary.Sound)
   
   self:TakePrimaryAmmo(1)
   
   self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
   
end

function SWEP:SecondaryAttack()

   if !self:CanSecondaryAttack() then return end
   
   self.Owner:SetAnimation(PLAYER_ATTACK1)
   
   if SERVER then
   
      local explodePos = self.Owner:GetEyeTrace().HitPos
      
      local explosion = ents.Create("env_explosion")
      explosion:SetPos(explodePos)
      explosion:SetOwner(self.Owner)
      explosion:SetKeyValue("iMagnitude", self.ExplosionDamage)
      explosion:Spawn()
      explosion:Fire("Explode", "", 0)
      
      -- Apply the explosion force to all players within the radius
      for _, ply in pairs(player.GetAll()) do
         local distance = ply:GetPos():Distance(explodePos)
         if distance <= self.ExplosionRadius then
            local push = (1 - (distance / self.ExplosionRadius)) * 900 -- Push force decreases with distance
            local direction = (ply:GetPos() - explodePos):GetNormalized()
            direction.z = direction.z + 0.5 -- Add upward force
            ply:SetVelocity(direction * push)
         end
      end
      
      self:EmitSound("weapons/explode3.wav", 100, 100)
      
      self:TakeSecondaryAmmo(1)
      
      self:SetNextSecondaryFire(CurTime() + 0.65)
      
   end
   
end

function SWEP:CanPrimaryAttack()

   if self.Weapon:Clip1() <= 0 then
      self:EmitSound("weapons/357/357_empty.wav")
      self:SetNextPrimaryFire(CurTime() + 0.2)
      return false
   end
   
   return true
   
end

function SWEP:CanSecondaryAttack()

   if self.Weapon:Clip1() <= 0 then
      self:EmitSound("weapons/357/357_empty.wav")
      self:SetNextPrimaryFire(CurTime() + 0.2)
      return false
   end
   
   return true
   
end

function SWEP:Think()

   if self.Weapon:Clip1() == 0 and self.Owner:GetAmmoCount(self.Weapon:GetPrimaryAmmoType()) > 0 then
      self:Reload()
   end
   
end

function SWEP:Reload()

   if self.Weapon:Clip1() == self.Primary.ClipSize then return end
   
   self.Owner:SetAnimation(PLAYER_RELOAD)
   
   self.Weapon:DefaultReload(ACT_VM_RELOAD)
   
end
