--====================================================================================================
-- COSMOS ODYSSEY - COMPLETE CLIENT-SIDE SPACE EXPLORATION, AURA RNG & FPS SANDBOX
-- Arquitetura: Single-File Modular LocalScript (Compatível com Delta Mobile/PC & StarterPlayerScripts)
--====================================================================================================
-- PARTE 1/4: CORE ENGINE, CONFIG, DATA TABLES, AUDIO & CAMERA FX
--====================================================================================================

if _G.__CosmosCleanup then
    pcall(_G.__CosmosCleanup)
    _G.__CosmosCleanup = nil
end

local Cosmos = {
    Version = "4.0.0-ARGON",
    Active = true,
    Started = false,
    Paused = false,
    QualityLevel = 3, -- 3 = Alta, 2 = Média, 1 = Baixa
    DynamicQuality = true,
    BatterySaver = false,
    DebugVisible = false,
    TimeElapsed = 0,
    FrameCount = 0,
    CurrentFPS = 60,
    ActivePartsCount = 0,
    Modules = {},
    ModuleOrder = {},
    ModuleTimings = {},
    State = {
        InSpace = false,
        SpaceFactor = 0,
        Altitude = 0,
        Speed = 0,
        CurrentBody = nil,
        NearestBody = nil,
        NearestDist = 999999,
        Flying = false,
        FlightMode = 1, -- 1 = Normal, 2 = Turbo, 3 = Hiper-velocidade
        WalkingOnPlanet = false,
        WalkBody = nil,
        Health = 100,
        MaxHealth = 100,
        Shield = 100,
        MaxShield = 100,
        Stamina = 100,
        MaxStamina = 100,
        Oxygen = 100,
        MaxOxygen = 100,
        XP = 0,
        Level = 1,
        EquippedSlot = 1,
        EquippedAura = nil,
        RollingAura = false,
        AutoRoll = false,
        TotalRolls = 0,
        PityCounter = 0,
        BestAuraIndex = 0,
        BaseLuck = 1.0,
        BonusLuck = 0.0,
        LuckTimer = 0,
        Aiming = false,
        Shooting = false,
        FirstPerson = false,
        CurrentWeapon = 1,
        EnemiesKilled = 0,
        BossesKilled = 0,
        PropsDestroyed = 0,
        PlanetsVisited = {},
        UnlockedAuras = {},
        AuraCounts = {},
        CompletedMissions = {},
        UnlockedAchievements = {},
        TouchInputs = {
            MoveVector = Vector3.zero,
            Ascend = false,
            Descend = false,
            Boost = false,
            Brake = false,
            Fire = false,
            Aim = false,
        }
    }
}

--====================================================================================================
-- [SEÇÃO 01] SERVIÇOS E REFERÊNCIAS GLOBAIS SEGURAS
--====================================================================================================
local Services = {
    Players = game:GetService("Players"),
    RunService = game:GetService("RunService"),
    UserInputService = game:GetService("UserInputService"),
    TweenService = game:GetService("TweenService"),
    Lighting = game:GetService("Lighting"),
    SoundService = game:GetService("SoundService"),
    Workspace = game:GetService("Workspace"),
    GuiService = game:GetService("GuiService"),
    StarterGui = game:GetService("StarterGui"),
    Debris = game:GetService("Debris"),
}

local LocalPlayer = Services.Players.LocalPlayer
local Camera = Services.Workspace.CurrentCamera

--====================================================================================================
-- [SEÇÃO 02] CONFIGURAÇÃO CENTRAL (CONFIG) E TABELAS DE DADOS
--====================================================================================================
local CONFIG = {
    SeedUniverse = 10492851,
    SeedFX = 99481723,
    MaxActiveParts = 1950,
    AltStart = 1200,
    AltFull = 3800,
    UniverseCenter = Vector3.new(0, 14000, 0),
    SunPosition = Vector3.new(0, 16000, -18000),
    SunRadius = 1600,
    StarCount = { [1] = 200, [2] = 400, [3] = 600 },
    StarShellRadius = 1800,
    AsteroidCount = { [1] = 55, [2] = 100, [3] = 150 },
    BeltCenter = Vector3.new(0, 15500, -6500),
    BeltRadiusInner = 2800,
    BeltRadiusOuter = 4200,
    NebulaCount = 6,
    Flight = {
        NormalSpeed = 140,
        TurboSpeed = 360,
        HyperSpeed = 950,
        Accel = 6.5,
        Decel = 5.0,
        TurnSpeed = 8.0,
        BankAngleMax = 38,
        SonicBoomSpeed = 310,
        StaminaDrainTurbo = 8.0,
        StaminaDrainHyper = 18.0,
        StaminaRegen = 14.0,
        BaseFOV = 70,
        TurboFOV = 92,
        HyperFOV = 114,
    },
    Gravity = {
        EngageMultiplier = 1.28,
        DisengageMultiplier = 1.45,
        DefaultLunarGravity = 38,
        JumpImpulse = 68,
        WalkSpeed = 24,
        AlignResponsiveness = 10,
    },
    Oxygen = {
        DrainRate = 2.2,
        RegenRate = 18.0,
        ZeroDamageRate = 8.0,
    },
    Aura = {
        RollCooldown = 1.8,
        PityThreshold = 50,
        MinSuspenseTime = 1.6,
        MaxSuspenseTime = 5.2,
    },
    Combat = {
        DefaultFOV = 70,
        ADSFOV = 46,
        HitmarkerDuration = 0.18,
        MaxProjectiles = 60,
        MaxShells = 25,
    },
    Enemies = {
        MaxActive = 12,
        SpawnInterval = 9.0,
        WaveMultiplier = 1.18,
    },
    Props = {
        MaxDebris = 65,
        RespawnTime = 28.0,
    },
    UI = {
        BgColor = Color3.fromRGB(8, 20, 24),
        PanelColor = Color3.fromRGB(12, 28, 34),
        StrokeColor = Color3.fromRGB(0, 225, 205),
        AccentColor = Color3.fromRGB(45, 255, 220),
        WarnColor = Color3.fromRGB(255, 175, 40),
        DangerColor = Color3.fromRGB(255, 65, 75),
        TextColor = Color3.fromRGB(230, 252, 255),
        SubTextColor = Color3.fromRGB(145, 195, 205),
    }
}

-- Tabela dos Corpos Celestes (Planetas e Luas)
local BODIES = {
    {
        Id = "TerraPrime",
        Name = "Terra Prime",
        Type = "Terra",
        Radius = 620,
        OrbitCenter = Vector3.new(0, 8500, 0),
        SemiMajor = 3400,
        Eccentricity = 0.05,
        Inclination = 6,
        OrbitSpeed = 0.012,
        RotationSpeed = 0.14,
        Phase = 0.2,
        Color = Color3.fromRGB(28, 105, 195),
        SecondaryColor = Color3.fromRGB(46, 150, 72),
        AtmosphereColor = Color3.fromRGB(95, 185, 255),
        HasAtmosphere = true,
        HasClouds = true,
        HasCityLights = true,
        Walkable = true,
        SurfaceGravity = 55,
        Description = "Berço da humanidade com oceanos profundos, nuvens dinâmicas e metrópoles iluminadas no hemisfério noturno.",
        Moons = {
            {
                Id = "LunaAlpha",
                Name = "Luna Alpha",
                Radius = 170,
                OrbitRadius = 1150,
                OrbitSpeed = 0.065,
                Inclination = 12,
                Phase = 1.1,
                Color = Color3.fromRGB(165, 170, 178),
                CraterColor = Color3.fromRGB(115, 120, 128),
                Walkable = true,
                SurfaceGravity = 26,
                Description = "Satélite natural repleto de crateras antigas e gravidade reduzida ideal para caminhada espacial."
            }
        }
    },
    {
        Id = "AresV",
        Name = "Ares V",
        Type = "Mars",
        Radius = 460,
        OrbitCenter = Vector3.new(0, 11800, -3200),
        SemiMajor = 5600,
        Eccentricity = 0.12,
        Inclination = 11,
        OrbitSpeed = 0.009,
        RotationSpeed = 0.11,
        Phase = 1.8,
        Color = Color3.fromRGB(205, 82, 42),
        SecondaryColor = Color3.fromRGB(240, 245, 255),
        AtmosphereColor = Color3.fromRGB(235, 130, 80),
        HasAtmosphere = true,
        HasPolarCaps = true,
        Walkable = true,
        SurfaceGravity = 38,
        Description = "Mundo desértico de óxido de ferro com imensas calotas polares de gelo seco e tempestades avermelhadas.",
        Moons = {
            {
                Id = "PhobosX",
                Name = "Phobos X",
                Radius = 110,
                OrbitRadius = 820,
                OrbitSpeed = 0.09,
                Inclination = 8,
                Phase = 0.5,
                Color = Color3.fromRGB(135, 115, 105),
                CraterColor = Color3.fromRGB(92, 78, 70),
                Walkable = true,
                SurfaceGravity = 20,
                Description = "Rocha irregular capturada pela gravidade marciana, rica em minérios raros."
            },
            {
                Id = "DeimosX",
                Name = "Deimos X",
                Radius = 85,
                OrbitRadius = 1180,
                OrbitSpeed = 0.055,
                Inclination = 18,
                Phase = 3.2,
                Color = Color3.fromRGB(150, 135, 125),
                CraterColor = Color3.fromRGB(100, 90, 85),
                Walkable = true,
                SurfaceGravity = 16,
                Description = "Posto avançado natural na órbita externa de Ares V."
            }
        }
    },
    {
        Id = "HyperionGas",
        Name = "Hyperion IX",
        Type = "GasGiant",
        Radius = 960,
        OrbitCenter = Vector3.new(0, 16500, -7500),
        SemiMajor = 8400,
        Eccentricity = 0.08,
        Inclination = 16,
        OrbitSpeed = 0.0055,
        RotationSpeed = 0.22,
        Phase = 3.4,
        Color = Color3.fromRGB(215, 175, 115),
        SecondaryColor = Color3.fromRGB(175, 110, 68),
        AtmosphereColor = Color3.fromRGB(255, 210, 145),
        HasAtmosphere = true,
        HasRings = true,
        RingInner = 1280,
        RingOuter = 2020,
        Walkable = false,
        SurfaceGravity = 90,
        Description = "Colosso gasoso cercado por um duplo sistema de anéis de gelo e poeira estelar.",
        Moons = {
            {
                Id = "Titanis",
                Name = "Titanis",
                Radius = 210,
                OrbitRadius = 2450,
                OrbitSpeed = 0.045,
                Inclination = 14,
                Phase = 2.1,
                Color = Color3.fromRGB(215, 165, 75),
                CraterColor = Color3.fromRGB(155, 115, 45),
                Walkable = true,
                SurfaceGravity = 30,
                Description = "A maior lua de Hyperion IX, com atmosfera densa dourada e superfície sólida caminhável."
            },
            {
                Id = "Encelad",
                Name = "Encelad",
                Radius = 140,
                OrbitRadius = 3100,
                OrbitSpeed = 0.032,
                Inclination = 6,
                Phase = 4.5,
                Color = Color3.fromRGB(220, 240, 255),
                CraterColor = Color3.fromRGB(165, 195, 225),
                Walkable = true,
                SurfaceGravity = 22,
                Description = "Lua glacial que reflete a luz solar como um espelho cósmico."
            }
        }
    },
    {
        Id = "CryoNova",
        Name = "Cryo Nova",
        Type = "Ice",
        Radius = 540,
        OrbitCenter = Vector3.new(0, 19500, -11000),
        SemiMajor = 11200,
        Eccentricity = 0.14,
        Inclination = 22,
        OrbitSpeed = 0.004,
        RotationSpeed = 0.09,
        Phase = 4.9,
        Color = Color3.fromRGB(115, 215, 255),
        SecondaryColor = Color3.fromRGB(190, 245, 255),
        AtmosphereColor = Color3.fromRGB(130, 230, 255),
        HasAtmosphere = true,
        HasCrystals = true,
        Walkable = true,
        SurfaceGravity = 42,
        Description = "Planeta congelado com monolitos cristalinos gigantes que refratam a radiação das nebulosas.",
        Moons = {
            {
                Id = "Glacies",
                Name = "Glacies",
                Radius = 135,
                OrbitRadius = 980,
                OrbitSpeed = 0.06,
                Inclination = 20,
                Phase = 1.4,
                Color = Color3.fromRGB(175, 225, 245),
                CraterColor = Color3.fromRGB(120, 175, 205),
                Walkable = true,
                SurfaceGravity = 21,
                Description = "Fragmento de gelo eterno na órbita de Cryo Nova."
            }
        }
    },
    {
        Id = "VulcanPyre",
        Name = "Vulcan Pyre",
        Type = "Lava",
        Radius = 500,
        OrbitCenter = Vector3.new(0, 15200, -14200),
        SemiMajor = 4100,
        Eccentricity = 0.18,
        Inclination = 28,
        OrbitSpeed = 0.015,
        RotationSpeed = 0.08,
        Phase = 5.6,
        Color = Color3.fromRGB(24, 20, 22),
        SecondaryColor = Color3.fromRGB(255, 95, 15),
        AtmosphereColor = Color3.fromRGB(255, 80, 20),
        HasAtmosphere = false,
        HasLavaCracks = true,
        Walkable = true,
        SurfaceGravity = 48,
        Description = "Mundo vulcânico extremo de basalto negro cortado por rios tectônicos de magma incandescente.",
        Moons = {
            {
                Id = "CinderMoon",
                Name = "Cinder",
                Radius = 125,
                OrbitRadius = 910,
                OrbitSpeed = 0.08,
                Inclination = 15,
                Phase = 0.9,
                Color = Color3.fromRGB(55, 45, 45),
                CraterColor = Color3.fromRGB(255, 110, 25),
                Walkable = true,
                SurfaceGravity = 24,
                Description = "Lua vulcânica coberta de cinzas e fissuras térmicas."
            }
        }
    }
}

-- Tabela de Raridades e 24 Auras Cósmicas com Receitas Visuais Únicas
local RARITIES = {
    [1] = { Name = "COMUM",     Color = Color3.fromRGB(190, 205, 215), BgColor = Color3.fromRGB(20, 28, 34), Suspense = 1.5, Shake = 0.15 },
    [2] = { Name = "INCOMUM",   Color = Color3.fromRGB(75, 235, 130),  BgColor = Color3.fromRGB(14, 38, 24), Suspense = 2.0, Shake = 0.25 },
    [3] = { Name = "RARO",      Color = Color3.fromRGB(65, 175, 255),  BgColor = Color3.fromRGB(12, 26, 48), Suspense = 2.6, Shake = 0.40 },
    [4] = { Name = "ÉPICO",     Color = Color3.fromRGB(185, 85, 255),  BgColor = Color3.fromRGB(32, 14, 48), Suspense = 3.3, Shake = 0.65 },
    [5] = { Name = "LENDÁRIO",  Color = Color3.fromRGB(255, 195, 45),  BgColor = Color3.fromRGB(48, 34, 10), Suspense = 4.1, Shake = 0.95 },
    [6] = { Name = "MÍTICO",    Color = Color3.fromRGB(255, 55, 95),   BgColor = Color3.fromRGB(48, 10, 22), Suspense = 4.8, Shake = 1.35 },
    [7] = { Name = "CÓSMICO",   Color = Color3.fromRGB(120, 255, 245), BgColor = Color3.fromRGB(6, 18, 28),  Suspense = 5.6, Shake = 1.90 },
}

local AURAS = {
    -- COMUM (Tier 1)
    { Id = 1,  Name = "Stardust Whisper",   Tier = 1, Odds = 2,       Primary = Color3.fromRGB(200, 220, 255), Secondary = Color3.fromRGB(140, 170, 210), Rings = 1, Orbs = 2, Pillars = 0, SpinSpeed = 1.2, Pulse = 1.0, BlackHole = false },
    { Id = 2,  Name = "Lunar Breeze",       Tier = 1, Odds = 3,       Primary = Color3.fromRGB(180, 195, 205), Secondary = Color3.fromRGB(110, 130, 145), Rings = 1, Orbs = 3, Pillars = 0, SpinSpeed = 1.5, Pulse = 1.2, BlackHole = false },
    { Id = 3,  Name = "Meteor Spark",       Tier = 1, Odds = 4,       Primary = Color3.fromRGB(255, 180, 120), Secondary = Color3.fromRGB(190, 100, 60),  Rings = 1, Orbs = 3, Pillars = 0, SpinSpeed = 1.8, Pulse = 1.4, BlackHole = false },
    { Id = 4,  Name = "Orbital Static",     Tier = 1, Odds = 4,       Primary = Color3.fromRGB(150, 230, 255), Secondary = Color3.fromRGB(80, 150, 200),  Rings = 1, Orbs = 4, Pillars = 0, SpinSpeed = 2.0, Pulse = 1.5, BlackHole = false },
    -- INCOMUM (Tier 2)
    { Id = 5,  Name = "Aurora Pulse",       Tier = 2, Odds = 6,       Primary = Color3.fromRGB(70, 255, 165),  Secondary = Color3.fromRGB(40, 180, 220),  Rings = 2, Orbs = 4, Pillars = 0, SpinSpeed = 2.2, Pulse = 1.8, BlackHole = false },
    { Id = 6,  Name = "Comet Tail",         Tier = 2, Odds = 8,       Primary = Color3.fromRGB(120, 240, 255), Secondary = Color3.fromRGB(255, 255, 200), Rings = 2, Orbs = 5, Pillars = 1, SpinSpeed = 2.5, Pulse = 2.0, BlackHole = false },
    { Id = 7,  Name = "Ionized Halo",       Tier = 2, Odds = 10,      Primary = Color3.fromRGB(95, 255, 120),  Secondary = Color3.fromRGB(180, 255, 90),  Rings = 2, Orbs = 5, Pillars = 1, SpinSpeed = 2.7, Pulse = 2.1, BlackHole = false },
    { Id = 8,  Name = "Cryo Frostbite",     Tier = 2, Odds = 12,      Primary = Color3.fromRGB(130, 230, 255), Secondary = Color3.fromRGB(220, 250, 255), Rings = 2, Orbs = 6, Pillars = 1, SpinSpeed = 2.4, Pulse = 1.9, BlackHole = false },
    -- RARO (Tier 3)
    { Id = 9,  Name = "Solar Flare",        Tier = 3, Odds = 22,      Primary = Color3.fromRGB(255, 155, 35),  Secondary = Color3.fromRGB(255, 70, 20),   Rings = 2, Orbs = 6, Pillars = 2, SpinSpeed = 3.0, Pulse = 2.5, BlackHole = false },
    { Id = 10, Name = "Magnetar Shield",    Tier = 3, Odds = 30,      Primary = Color3.fromRGB(55, 155, 255),  Secondary = Color3.fromRGB(120, 220, 255), Rings = 3, Orbs = 6, Pillars = 2, SpinSpeed = 3.4, Pulse = 2.6, BlackHole = false },
    { Id = 11, Name = "Nebula Heart",       Tier = 3, Odds = 40,      Primary = Color3.fromRGB(235, 95, 215),  Secondary = Color3.fromRGB(95, 130, 255),  Rings = 3, Orbs = 7, Pillars = 2, SpinSpeed = 3.2, Pulse = 2.8, BlackHole = false },
    { Id = 12, Name = "Plasma Vortex",      Tier = 3, Odds = 55,      Primary = Color3.fromRGB(80, 200, 255),  Secondary = Color3.fromRGB(190, 90, 255),  Rings = 3, Orbs = 8, Pillars = 2, SpinSpeed = 3.8, Pulse = 3.0, BlackHole = false },
    -- ÉPICO (Tier 4)
    { Id = 13, Name = "Pulsar Storm",       Tier = 4, Odds = 110,     Primary = Color3.fromRGB(185, 75, 255),  Secondary = Color3.fromRGB(95, 245, 255),  Rings = 3, Orbs = 8, Pillars = 3, SpinSpeed = 4.2, Pulse = 3.4, BlackHole = false },
    { Id = 14, Name = "Void Walker",        Tier = 4, Odds = 160,     Primary = Color3.fromRGB(130, 45, 225),  Secondary = Color3.fromRGB(25, 10, 45),    Rings = 4, Orbs = 9, Pillars = 3, SpinSpeed = 4.5, Pulse = 3.6, BlackHole = false },
    { Id = 15, Name = "Supernova Remnant",  Tier = 4, Odds = 240,     Primary = Color3.fromRGB(255, 110, 210), Secondary = Color3.fromRGB(255, 215, 85),  Rings = 4, Orbs = 10, Pillars = 4, SpinSpeed = 4.8, Pulse = 3.8, BlackHole = false },
    { Id = 16, Name = "Dark Matter Surge",  Tier = 4, Odds = 350,     Primary = Color3.fromRGB(160, 50, 255),  Secondary = Color3.fromRGB(255, 50, 140),  Rings = 4, Orbs = 10, Pillars = 4, SpinSpeed = 5.0, Pulse = 4.0, BlackHole = false },
    -- LENDÁRIO (Tier 5)
    { Id = 17, Name = "Quasar Crown",       Tier = 5, Odds = 1000,    Primary = Color3.fromRGB(255, 215, 55),  Secondary = Color3.fromRGB(255, 125, 25),  Rings = 4, Orbs = 12, Pillars = 5, SpinSpeed = 5.5, Pulse = 4.5, BlackHole = false },
    { Id = 18, Name = "Starforge Sovereign",Tier = 5, Odds = 1800,    Primary = Color3.fromRGB(255, 235, 120), Secondary = Color3.fromRGB(80, 225, 255),  Rings = 5, Orbs = 12, Pillars = 6, SpinSpeed = 5.8, Pulse = 4.8, BlackHole = false },
    { Id = 19, Name = "Celestial Seraph",   Tier = 5, Odds = 3200,    Primary = Color3.fromRGB(255, 250, 195), Secondary = Color3.fromRGB(255, 180, 60),  Rings = 5, Orbs = 14, Pillars = 6, SpinSpeed = 6.2, Pulse = 5.0, BlackHole = false },
    -- MÍTICO (Tier 6)
    { Id = 20, Name = "Accretion Abyss",    Tier = 6, Odds = 10000,   Primary = Color3.fromRGB(255, 65, 95),   Secondary = Color3.fromRGB(255, 175, 55),  Rings = 5, Orbs = 14, Pillars = 7, SpinSpeed = 6.8, Pulse = 5.5, BlackHole = true },
    { Id = 21, Name = "Gamma Ray Hypernova",Tier = 6, Odds = 25000,   Primary = Color3.fromRGB(255, 45, 125),  Secondary = Color3.fromRGB(110, 255, 240), Rings = 6, Orbs = 16, Pillars = 8, SpinSpeed = 7.2, Pulse = 6.0, BlackHole = true },
    { Id = 22, Name = "Chronos Singularity",Tier = 6, Odds = 50000,   Primary = Color3.fromRGB(255, 85, 65),   Secondary = Color3.fromRGB(185, 85, 255),  Rings = 6, Orbs = 16, Pillars = 8, SpinSpeed = 7.6, Pulse = 6.4, BlackHole = true },
    -- CÓSMICO (Tier 7)
    { Id = 23, Name = "Event Horizon",      Tier = 7, Odds = 250000,  Primary = Color3.fromRGB(95, 255, 245),  Secondary = Color3.fromRGB(255, 130, 40),  Rings = 6, Orbs = 18, Pillars = 10, SpinSpeed = 8.4, Pulse = 7.0, BlackHole = true },
    { Id = 24, Name = "COSMOS ODYSSEY",     Tier = 7, Odds = 1000000, Primary = Color3.fromRGB(145, 255, 250), Secondary = Color3.fromRGB(255, 215, 90),  Rings = 7, Orbs = 20, Pillars = 12, SpinSpeed = 9.2, Pulse = 8.0, BlackHole = true },
}

-- Tabela de Armas (Combat FPS)
local WEAPONS = {
    [1] = {
        Id = "PulseRifle",
        Name = "Rifle de Pulso VX-9",
        Damage = 24,
        HeadshotMult = 2.0,
        FireRate = 0.11,
        Automatic = true,
        MagSize = 32,
        ReserveMax = 192,
        ReloadTime = 1.65,
        RecoilPitch = 1.3,
        RecoilYaw = 0.5,
        SpreadBase = 0.008,
        SpreadMax = 0.055,
        SpreadInc = 0.007,
        Range = 1400,
        Color = Color3.fromRGB(0, 240, 255),
        BodySize = Vector3.new(0.35, 0.45, 2.2),
    },
    [2] = {
        Id = "PlasmaPistol",
        Name = "Pistola de Plasma Ion-4",
        Damage = 38,
        HeadshotMult = 2.2,
        FireRate = 0.24,
        Automatic = false,
        MagSize = 12,
        ReserveMax = 96,
        ReloadTime = 1.2,
        RecoilPitch = 2.1,
        RecoilYaw = 0.7,
        SpreadBase = 0.005,
        SpreadMax = 0.04,
        SpreadInc = 0.01,
        Range = 950,
        Color = Color3.fromRGB(110, 255, 130),
        BodySize = Vector3.new(0.28, 0.38, 1.25),
    },
    [3] = {
        Id = "NovaCannon",
        Name = "Canhão de Antimatéria X-0",
        Damage = 115,
        HeadshotMult = 2.0,
        FireRate = 0.75,
        Automatic = false,
        MagSize = 5,
        ReserveMax = 35,
        ReloadTime = 2.3,
        RecoilPitch = 4.2,
        RecoilYaw = 1.2,
        SpreadBase = 0.002,
        SpreadMax = 0.03,
        SpreadInc = 0.018,
        Range = 2200,
        ExplosiveRadius = 28,
        Color = Color3.fromRGB(255, 120, 45),
        BodySize = Vector3.new(0.5, 0.58, 2.65),
    }
}

-- Tabela de Inimigos (Drones IA)
local ENEMY_TYPES = {
    Scout = {
        Name = "Drone Scout",
        MaxHealth = 75,
        Shield = 0,
        Speed = 62,
        DetectRange = 360,
        AttackRange = 240,
        FireRate = 0.9,
        Damage = 7,
        ProjectileSpeed = 230,
        Radius = 3.2,
        Color = Color3.fromRGB(255, 190, 50),
        XP = 35,
    },
    Gunner = {
        Name = "Drone Gunner",
        MaxHealth = 140,
        Shield = 40,
        Speed = 44,
        DetectRange = 420,
        AttackRange = 300,
        FireRate = 0.45,
        BurstCount = 3,
        Damage = 10,
        ProjectileSpeed = 270,
        Radius = 4.4,
        Color = Color3.fromRGB(255, 85, 55),
        XP = 65,
    },
    Heavy = {
        Name = "Drone Heavy",
        MaxHealth = 260,
        Shield = 120,
        Speed = 28,
        DetectRange = 480,
        AttackRange = 360,
        FireRate = 1.6,
        Damage = 22,
        Homing = true,
        ProjectileSpeed = 185,
        Radius = 6.0,
        Color = Color3.fromRGB(195, 65, 255),
        XP = 120,
    },
    Boss = {
        Name = "Guardião Estelar Omega",
        MaxHealth = 1200,
        Shield = 400,
        Speed = 36,
        DetectRange = 750,
        AttackRange = 550,
        FireRate = 0.75,
        Damage = 26,
        Homing = true,
        ProjectileSpeed = 240,
        Radius = 14.0,
        Color = Color3.fromRGB(255, 40, 90),
        XP = 600,
        IsBoss = true,
    }
}

-- Tabela de Missões e Conquistas
local MISSIONS = {
    { Id = "m_space",   Title = "Pioneiro Orbital",     Desc = "Voe até o espaço sideral (Altitude > 3.800m).",         Goal = 1,  RewardXP = 100, RewardLuck = 0.5 },
    { Id = "m_moon",    Title = "Passos Lunares",       Desc = "Pouse e caminhe sobre qualquer lua ou planeta.",        Goal = 1,  RewardXP = 150, RewardLuck = 0.5 },
    { Id = "m_aura5",   Title = "Iniciado do Acaso",    Desc = "Realize 5 rolagens de Auras Cósmicas.",                 Goal = 5,  RewardXP = 120, RewardLuck = 0.75 },
    { Id = "m_props10", Title = "Demolidor Orbital",    Desc = "Destrua 10 objetos/asteroides com suas armas.",         Goal = 10, RewardXP = 180, RewardLuck = 1.0 },
    { Id = "m_drones5", Title = "Caçador de Drones",    Desc = "Derrote 5 Drones Espaciais em combate.",                Goal = 5,  RewardXP = 250, RewardLuck = 1.5 },
    { Id = "m_planets", Title = "Cartógrafo Solar",     Desc = "Visite pelo menos 3 planetas diferentes.",              Goal = 3,  RewardXP = 300, RewardLuck = 2.0 },
    { Id = "m_aura25",  Title = "Mestre das Estrelas",  Desc = "Realize 25 rolagens de Auras Cósmicas.",                Goal = 25, RewardXP = 400, RewardLuck = 2.5 },
    { Id = "m_boss",    Title = "Regicida Cósmico",     Desc = "Derrote o chefe Guardião Estelar Omega.",               Goal = 1,  RewardXP = 800, RewardLuck = 5.0 },
}

local ACHIEVEMENTS = {
    { Id = "a_sonic",     Title = "Quebra-Barreira",    Desc = "Ultrapasse a velocidade sônica em voo Turbo ou Hiper." },
    { Id = "a_epic",      Title = "Brilho Raro",        Desc = "Obtenha uma Aura de raridade Épica ou superior." },
    { Id = "a_legend",    Title = "Escolhido do Cosmos",Desc = "Obtenha uma Aura Lendária, Mítica ou Cósmica." },
    { Id = "a_slayer",    Title = "Pacifista Reverso",  Desc = "Elimine 15 drones hostis no sistema solar." },
    { Id = "a_explorer",  Title = "Odisseia Completa",  Desc = "Visite todos os 5 planetas do sistema solar." },
}

--====================================================================================================
-- [SEÇÃO 03] UTILITÁRIOS: MAID, SIGNAL, POOL, SPRING, TWEEN & MATH HELPERS
--====================================================================================================
local Util = {}
Cosmos.Util = Util

-- Maid: Gerenciador de limpeza de conexões, instâncias e funções
local Maid = {}
Maid.__index = Maid

function Maid.new()
    return setmetatable({ _tasks = {} }, Maid)
end

function Maid:Add(taskItem)
    if not taskItem then return nil end
    table.insert(self._tasks, taskItem)
    return taskItem
end

function Maid:Clean()
    local tasks = self._tasks
    self._tasks = {}
    for i = #tasks, 1, -1 do
        local item = tasks[i]
        local t = typeof(item)
        if t == "RBXScriptConnection" then
            pcall(function() item:Disconnect() end)
        elseif t == "Instance" then
            pcall(function() item:Destroy() end)
        elseif t == "function" then
            pcall(item)
        elseif t == "table" and type(item.Destroy) == "function" then
            pcall(function() item:Destroy() end)
        elseif t == "table" and type(item.Clean) == "function" then
            pcall(function() item:Clean() end)
        end
    end
end

function Maid:Destroy()
    self:Clean()
end

Util.Maid = Maid
Cosmos.MasterMaid = Maid.new()

-- Signal leve para eventos internos
local Signal = {}
Signal.__index = Signal

function Signal.new()
    return setmetatable({ _listeners = {} }, Signal)
end

function Signal:Connect(fn)
    local listener = { fn = fn, connected = true }
    table.insert(self._listeners, listener)
    local selfRef = self
    return {
        Connected = true,
        Disconnect = function(conn)
            conn.Connected = false
            listener.connected = false
            for i = #selfRef._listeners, 1, -1 do
                if selfRef._listeners[i] == listener then
                    table.remove(selfRef._listeners, i)
                    break
                end
            end
        end
    }
end

function Signal:Fire(...)
    for i = 1, #self._listeners do
        local l = self._listeners[i]
        if l and l.connected then
            task.spawn(l.fn, ...)
        end
    end
end

function Signal:Destroy()
    table.clear(self._listeners)
end

Util.Signal = Signal

-- Object Pool para evitar Instance.new em loops por frame
local Pool = {}
Pool.__index = Pool

function Pool.new(createFn, resetFn, initialSize)
    local self = setmetatable({
        _create = createFn,
        _reset = resetFn,
        _free = {},
        _active = {},
    }, Pool)
    for _ = 1, (initialSize or 0) do
        local obj = self._create()
        if obj then
            table.insert(self._free, obj)
        end
    end
    return self
end

function Pool:Acquire()
    local obj = table.remove(self._free)
    if not obj then
        obj = self._create()
    end
    self._active[obj] = true
    return obj
end

function Pool:Release(obj)
    if not obj or not self._active[obj] then return end
    self._active[obj] = nil
    if self._reset then
        pcall(self._reset, obj)
    end
    table.insert(self._free, obj)
end

function Pool:ReleaseAll()
    for obj in pairs(self._active) do
        if self._reset then
            pcall(self._reset, obj)
        end
        table.insert(self._free, obj)
    end
    table.clear(self._active)
end

function Pool:Destroy()
    for obj in pairs(self._active) do
        if typeof(obj) == "Instance" then
            pcall(function() obj:Destroy() end)
        end
    end
    for _, obj in ipairs(self._free) do
        if typeof(obj) == "Instance" then
            pcall(function() obj:Destroy() end)
        end
    end
    table.clear(self._active)
    table.clear(self._free)
end

Util.Pool = Pool

-- Mola crítica amortecida (Spring) para câmera, recuo e UI
local Spring = {}
Spring.__index = Spring

function Spring.new(initial, speed, damper)
    return setmetatable({
        Target = initial or 0,
        Position = initial or 0,
        Velocity = (type(initial) == "vector" or typeof(initial) == "Vector3") and Vector3.zero or 0,
        Speed = speed or 16,
        Damper = damper or 0.85,
    }, Spring)
end

function Spring:Impulse(velocity)
    self.Velocity = self.Velocity + velocity
end

function Spring:Update(dt)
    dt = math.min(dt, 0.1)
    local force = (self.Target - self.Position) * (self.Speed * self.Speed)
    local drag = self.Velocity * (2 * self.Damper * self.Speed)
    local accel = force - drag
    self.Velocity = self.Velocity + accel * dt
    self.Position = self.Position + self.Velocity * dt
    return self.Position
end

Util.Spring = Spring

-- Funções Matemáticas e de Criação de Parts
function Util.Clamp(x, a, b)
    if x < a then return a end
    if x > b then return b end
    return x
end

function Util.Lerp(a, b, t)
    return a + (b - a) * Util.Clamp(t, 0, 1)
end

function Util.LerpColor(c1, c2, t)
    return c1:Lerp(c2, Util.Clamp(t, 0, 1))
end

function Util.SmoothStep(edge0, edge1, x)
    local t = Util.Clamp((x - edge0) / math.max(0.0001, edge1 - edge0), 0, 1)
    return t * t * (3 - 2 * t)
end

function Util.FormatNumber(n)
    local formatted = tostring(math.floor(n))
    local k
    while true do
        formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", "%1,%2")
        if k == 0 then break end
    end
    return formatted
end

function Util.Tween(instance, duration, style, direction, props)
    local info = TweenInfo.new(
        duration or 0.25,
        style or Enum.EasingStyle.Quad,
        direction or Enum.EasingDirection.Out
    )
    local tw = Services.TweenService:Create(instance, info, props)
    tw:Play()
    return tw
end

-- Criador padronizado de Parts decorativas respeitando limite de 2048 studs
function Util.CreatePart(props)
    local part = Instance.new("Part")
    part.Anchored = (props.Anchored ~= nil) and props.Anchored or true
    part.CanCollide = props.CanCollide or false
    part.CanQuery = props.CanQuery or false
    part.CanTouch = props.CanTouch or false
    part.CastShadow = props.CastShadow or false
    part.TopSurface = Enum.SurfaceType.Smooth
    part.BottomSurface = Enum.SurfaceType.Smooth
    part.Material = props.Material or Enum.Material.SmoothPlastic
    part.Color = props.Color or Color3.fromRGB(255, 255, 255)
    part.Transparency = props.Transparency or 0
    if props.Shape then
        part.Shape = props.Shape
    end
    if props.Size then
        local sx = math.min(props.Size.X, 2048)
        local sy = math.min(props.Size.Y, 2048)
        local sz = math.min(props.Size.Z, 2048)
        part.Size = Vector3.new(sx, sy, sz)
        -- Se precisar parecer maior que 2048 studs, usa SpecialMesh com Scale
        if props.Size.X > 2048 or props.Size.Y > 2048 or props.Size.Z > 2048 then
            local mesh = Instance.new("SpecialMesh")
            mesh.MeshType = (props.Shape == Enum.PartType.Ball) and Enum.MeshType.Sphere or Enum.MeshType.Brick
            mesh.Scale = Vector3.new(props.Size.X / sx, props.Size.Y / sy, props.Size.Z / sz)
            mesh.Parent = part
        end
    end
    if props.CFrame then
        part.CFrame = props.CFrame
    elseif props.Position then
        part.Position = props.Position
    end
    if props.Name then
        part.Name = props.Name
    end
    if props.Parent then
        part.Parent = props.Parent
    end
    Cosmos.ActivePartsCount = Cosmos.ActivePartsCount + 1
    return part
end

function Util.GetCharacter()
    local char = LocalPlayer and LocalPlayer.Character
    if not char then return nil, nil, nil end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChildOfClass("Humanoid")
    return char, hrp, hum
end

function Util.RegisterModule(name, modTable)
    Cosmos.Modules[name] = modTable
    table.insert(Cosmos.ModuleOrder, name)
end

-- Pasta raiz de instâncias 3D no Workspace
local WorldFolder = Instance.new("Folder")
WorldFolder.Name = "__CosmosOdysseyWorld"
WorldFolder.Parent = Services.Workspace
Cosmos.WorldFolder = WorldFolder
Cosmos.MasterMaid:Add(WorldFolder)

--====================================================================================================
-- [SEÇÃO 04] MÓDULO 11: AUDIO LOCAL (SONS PROCEDURAIS E FALLBACK SILENCIOSO)
--====================================================================================================
local Audio = {
    Maid = Maid.new(),
    Enabled = true,
    MasterVolume = 0.8,
    SFXVolume = 0.9,
    MusicVolume = 0.45,
    SpaceMuffle = 0,
    Sounds = {},
    Equalizer = nil,
}
Util.RegisterModule("Audio", Audio)

local SOUND_DEFS = {
    UIClick       = { Id = "rbxassetid://9119713951", Pitch = 1.15, Volume = 0.45 },
    UIHover       = { Id = "rbxassetid://9119720940", Pitch = 1.35, Volume = 0.25 },
    Notify        = { Id = "rbxassetid://9118823108", Pitch = 1.05, Volume = 0.55 },
    LaserRifle    = { Id = "rbxassetid://9114221580", Pitch = 1.10, Volume = 0.55 },
    PlasmaShot    = { Id = "rbxassetid://9114221580", Pitch = 0.85, Volume = 0.65 },
    NovaShot      = { Id = "rbxassetid://9114221580", Pitch = 0.55, Volume = 0.85 },
    Reload        = { Id = "rbxassetid://9113632459", Pitch = 1.00, Volume = 0.50 },
    Hitmarker     = { Id = "rbxassetid://9114487369", Pitch = 1.35, Volume = 0.65 },
    Explosion     = { Id = "rbxassetid://9114224721", Pitch = 0.80, Volume = 0.85 },
    SonicBoom     = { Id = "rbxassetid://9114224721", Pitch = 0.60, Volume = 0.95 },
    FlightLoop    = { Id = "rbxassetid://9114397505", Pitch = 1.00, Volume = 0.35, Looped = true },
    SpaceDrone    = { Id = "rbxassetid://9112764893", Pitch = 0.65, Volume = 0.30, Looped = true },
    AuraCharge    = { Id = "rbxassetid://9118823108", Pitch = 0.70, Volume = 0.60 },
    AuraTick      = { Id = "rbxassetid://9119713951", Pitch = 1.40, Volume = 0.45 },
    AuraRevealLow = { Id = "rbxassetid://9118828562", Pitch = 1.00, Volume = 0.75 },
    AuraRevealHigh= { Id = "rbxassetid://9114224721", Pitch = 1.15, Volume = 0.95 },
}

function Audio:Init()
    local folder = Instance.new("SoundGroup")
    folder.Name = "__CosmosSoundGroup"
    folder.Volume = self.MasterVolume
    folder.Parent = Services.SoundService
    self.Group = folder
    self.Maid:Add(folder)

    local eq = Instance.new("EqualizerSoundEffect")
    eq.HighGain = 0
    eq.MidGain = 0
    eq.LowGain = 0
    eq.Parent = folder
    self.Equalizer = eq

    local rev = Instance.new("ReverbSoundEffect")
    rev.DecayTime = 1.8
    rev.WetLevel = -18
    rev.DryLevel = 0
    rev.Parent = folder
    self.Reverb = rev

    for name, def in pairs(SOUND_DEFS) do
        local s = Instance.new("Sound")
        s.Name = name
        s.SoundId = def.Id
        s.PlaybackSpeed = def.Pitch or 1
        s.Volume = (def.Volume or 0.5) * self.SFXVolume
        s.Looped = def.Looped or false
        s.SoundGroup = folder
        s.Parent = folder
        self.Sounds[name] = s
    end

    pcall(function()
        self.Sounds.SpaceDrone:Play()
        self.Sounds.FlightLoop:Play()
        self.Sounds.FlightLoop.Volume = 0
    end)
end

function Audio:Play(name, pitchShift, volMult)
    if not self.Enabled or Cosmos.BatterySaver then return end
    local base = self.Sounds[name]
    if not base then return end
    pcall(function()
        local def = SOUND_DEFS[name]
        base.PlaybackSpeed = (def.Pitch or 1) * (pitchShift or 1)
        local spaceAtten = 1 - (self.SpaceMuffle * 0.35)
        base.Volume = (def.Volume or 0.5) * self.SFXVolume * (volMult or 1) * spaceAtten
        base:Play()
    end)
end

function Audio:Update(dt)
    local sf = Cosmos.State.SpaceFactor
    self.SpaceMuffle = Util.Lerp(self.SpaceMuffle, sf, dt * 4)
    if self.Equalizer then
        -- Efeito de vácuo espacial: reduz frequências agudas e realça graves internos do traje
        self.Equalizer.HighGain = -18 * self.SpaceMuffle
        self.Equalizer.MidGain = -8 * self.SpaceMuffle
        self.Equalizer.LowGain = 3 * self.SpaceMuffle
    end
    if self.Sounds.SpaceDrone then
        self.Sounds.SpaceDrone.Volume = self.MusicVolume * (0.15 + 0.35 * sf) * (self.Enabled and 1 or 0)
    end
    if self.Sounds.FlightLoop then
        if Cosmos.State.Flying and self.Enabled then
            local spdRatio = Util.Clamp(Cosmos.State.Speed / CONFIG.Flight.HyperSpeed, 0, 1)
            self.Sounds.FlightLoop.Volume = Util.Lerp(self.Sounds.FlightLoop.Volume, spdRatio * 0.55 * self.SFXVolume, dt * 6)
            self.Sounds.FlightLoop.PlaybackSpeed = 0.75 + spdRatio * 1.15
        else
            self.Sounds.FlightLoop.Volume = Util.Lerp(self.Sounds.FlightLoop.Volume, 0, dt * 8)
        end
    end
end

function Audio:Destroy()
    self.Maid:Clean()
end

--====================================================================================================
-- [SEÇÃO 05] MÓDULO 12: CAMERA FX (SHAKE, FOV DINÂMICO, BLUR, TILT, CINEMÁTICA)
--====================================================================================================
local CameraFX = {
    Maid = Maid.new(),
    ShakePower = 0,
    ShakeDecay = 6,
    TargetFOV = 70,
    CurrentFOV = 70,
    RollAngle = 0,
    TargetRoll = 0,
    BlurEffect = nil,
    CinematicActive = false,
    IntroActive = true,
    IntroAngle = 0,
    FlashColor = Color3.new(1, 1, 1),
    FlashAlpha = 0,
    VignetteAlpha = 0.15,
    CustomUpVector = Vector3.yAxis,
}
Util.RegisterModule("CameraFX", CameraFX)

function CameraFX:Init()
    self.OriginalFOV = Camera and Camera.FieldOfView or 70

    local blur = Instance.new("BlurEffect")
    blur.Name = "__CosmosMotionBlur"
    blur.Size = 0
    blur.Parent = Services.Lighting
    self.BlurEffect = blur
    self.Maid:Add(blur)
end

function CameraFX:Shake(intensity, decay)
    self.ShakePower = math.max(self.ShakePower, intensity or 0.5)
    self.ShakeDecay = decay or 6.0
end

function CameraFX:Flash(color, alpha)
    self.FlashColor = color or Color3.new(1, 1, 1)
    self.FlashAlpha = Util.Clamp(alpha or 0.85, 0, 1)
end

function CameraFX:SetRoll(deg)
    self.TargetRoll = deg or 0
end

function CameraFX:Update(dt)
    Camera = Services.Workspace.CurrentCamera
    if not Camera then return end

    -- Atualizar decaimento de Flash e Shake
    if self.FlashAlpha > 0 then
        self.FlashAlpha = math.max(0, self.FlashAlpha - dt * 2.2)
    end
    if self.ShakePower > 0 then
        self.ShakePower = math.max(0, self.ShakePower - dt * self.ShakeDecay)
    end

    -- Câmera de Introdução sobre a Terra Prime antes do jogador clicar em JOGAR
    if self.IntroActive and not Cosmos.Started then
        self.IntroAngle = self.IntroAngle + dt * 0.18
        local terraPos = Vector3.new(3400, 8500, 0)
        if Cosmos.Modules.Universe and Cosmos.Modules.Universe.GetBodyPosition then
            terraPos = Cosmos.Modules.Universe:GetBodyPosition("TerraPrime") or terraPos
        end
        local camOffset = Vector3.new(math.cos(self.IntroAngle) * 1150, 320, math.sin(self.IntroAngle) * 1150)
        Camera.CameraType = Enum.CameraType.Scriptable
        Camera.CFrame = CFrame.lookAt(terraPos + camOffset, terraPos + Vector3.new(0, 80, 0))
        Camera.FieldOfView = 62
        return
    elseif Camera.CameraType == Enum.CameraType.Scriptable and not self.CinematicActive then
        Camera.CameraType = Enum.CameraType.Custom
    end

    -- Cálculo de FOV dinâmico (Voo, Mira ADS, Cinemática)
    local desiredFOV = CONFIG.Flight.BaseFOV
    if Cosmos.State.RollingAura then
        desiredFOV = 52
    elseif Cosmos.State.Aiming then
        desiredFOV = CONFIG.Combat.ADSFOV
    elseif Cosmos.State.Flying then
        local spd = Cosmos.State.Speed
        if Cosmos.State.FlightMode == 3 then
            desiredFOV = CONFIG.Flight.HyperFOV
        elseif Cosmos.State.FlightMode == 2 then
            desiredFOV = CONFIG.Flight.TurboFOV
        else
            desiredFOV = Util.Lerp(CONFIG.Flight.BaseFOV, CONFIG.Flight.TurboFOV, Util.Clamp(spd / CONFIG.Flight.TurboSpeed, 0, 1))
        end
    end

    self.CurrentFOV = Util.Lerp(self.CurrentFOV, desiredFOV, dt * 8)
    Camera.FieldOfView = self.CurrentFOV

    -- Motion Blur falso proporcional à velocidade
    if self.BlurEffect then
        if Cosmos.QualityLevel >= 2 and not Cosmos.BatterySaver then
            local spdBlur = Util.Clamp((Cosmos.State.Speed - 180) / 500, 0, 1) * 8
            local shakeBlur = self.ShakePower * 3
            self.BlurEffect.Size = Util.Lerp(self.BlurEffect.Size, spdBlur + shakeBlur, dt * 10)
        else
            self.BlurEffect.Size = 0
        end
    end

    -- Aplicar Shake e Tilt/Roll na câmera
    self.RollAngle = Util.Lerp(self.RollAngle, self.TargetRoll, dt * 7)
    local shakeOffset = Vector3.zero
    local shakeRot = Vector3.zero
    if self.ShakePower > 0.001 then
        local p = self.ShakePower
        shakeOffset = Vector3.new(
            (math.random() - 0.5) * 2 * p,
            (math.random() - 0.5) * 2 * p,
            (math.random() - 0.5) * 2 * p
        )
        shakeRot = Vector3.new(
            (math.random() - 0.5) * 0.06 * p,
            (math.random() - 0.5) * 0.06 * p,
            (math.random() - 0.5) * 0.06 * p
        )
    end

    if math.abs(self.RollAngle) > 0.05 or self.ShakePower > 0.001 then
        Camera.CFrame = Camera.CFrame
            * CFrame.new(shakeOffset)
            * CFrame.Angles(shakeRot.X, shakeRot.Y, math.rad(self.RollAngle) + shakeRot.Z)
    end
end

function CameraFX:Destroy()
    if Camera then
        pcall(function()
            Camera.FieldOfView = self.OriginalFOV or 70
            Camera.CameraType = Enum.CameraType.Custom
        end)
    end
    self.Maid:Clean()
end
-- CONTINUA NA PARTE 2/4

--====================================================================================================
-- PARTE 2/4: UNIVERSE ENGINE, ATMOSPHERE TRANSITION, SUPERMAN FLIGHT & PLANET WALK
--====================================================================================================

--====================================================================================================
-- [SEÇÃO 06] MÓDULO 2: UNIVERSE (SISTEMA SOLAR VIVO, SOL, PLANETAS, LUAS, ASTEROIDES, ESTRELAS)
--====================================================================================================
local Universe = {
    Maid = Maid.new(),
    Folder = nil,
    SunModel = nil,
    CoronaInner = nil,
    CoronaOuter = nil,
    SunRays = {},
    BodyRuntimes = {},
    BodyMap = {},
    Asteroids = {},
    StarParts = {},
    StarShellFolder = nil,
    Nebulas = {},
    Comet = nil,
    CometTimer = 12,
    SimTime = 0,
}
Util.RegisterModule("Universe", Universe)

function Universe:BuildSun()
    local sunFolder = Instance.new("Model")
    sunFolder.Name = "SolarStar"
    sunFolder.Parent = self.Folder
    self.SunModel = sunFolder

    local sunPos = CONFIG.SunPosition
    local r = CONFIG.SunRadius

    local core = Util.CreatePart({
        Name = "SunCore",
        Shape = Enum.PartType.Ball,
        Material = Enum.Material.Neon,
        Color = Color3.fromRGB(255, 225, 115),
        Size = Vector3.new(r, r, r),
        Position = sunPos,
        Parent = sunFolder
    })
    self.SunCore = core

    -- Duas camadas de corona que pulsam com seno
    self.CoronaInner = Util.CreatePart({
        Name = "CoronaInner",
        Shape = Enum.PartType.Ball,
        Material = Enum.Material.Neon,
        Color = Color3.fromRGB(255, 165, 45),
        Transparency = 0.55,
        Size = Vector3.new(r * 1.18, r * 1.18, r * 1.18),
        Position = sunPos,
        Parent = sunFolder
    })

    self.CoronaOuter = Util.CreatePart({
        Name = "CoronaOuter",
        Shape = Enum.PartType.Ball,
        Material = Enum.Material.Neon,
        Color = Color3.fromRGB(255, 95, 20),
        Transparency = 0.78,
        Size = Vector3.new(r * 1.38, r * 1.38, r * 1.38),
        Position = sunPos,
        Parent = sunFolder
    })

    -- Raios solares de Parts finas Neon que giram lentamente
    for i = 1, 10 do
        local angle1 = (i / 10) * math.pi * 2
        local angle2 = (i * 1.7)
        local ray = Util.CreatePart({
            Name = "SolarRay_" .. i,
            Material = Enum.Material.Neon,
            Color = Color3.fromRGB(255, 195, 70),
            Transparency = 0.65,
            Size = Vector3.new(38, 38, r * 1.75),
            CFrame = CFrame.new(sunPos) * CFrame.Angles(angle1, angle2, 0),
            Parent = sunFolder
        })
        table.insert(self.SunRays, { Part = ray, A1 = angle1, A2 = angle2, Speed = 0.06 + (i % 3) * 0.03 })
    end
end

function Universe:BuildPlanet(def)
    local model = Instance.new("Model")
    model.Name = def.Id
    model.Parent = self.Folder

    local d = def.Radius * 2
    local root = Util.CreatePart({
        Name = "Core",
        Shape = Enum.PartType.Ball,
        Material = (def.Type == "Lava") and Enum.Material.Slate or Enum.Material.SmoothPlastic,
        Color = def.Color,
        Size = Vector3.new(d, d, d),
        Position = def.OrbitCenter,
        Parent = model
    })
    model.PrimaryPart = root

    -- Simulação de iluminação solar: hemisfério de sombra oposto ao Sol
    -- Truque técnico: uma esfera preta com transparência 0.42 ligeiramente deslocada na direção oposta ao Sol
    local shadowPart = Util.CreatePart({
        Name = "DayNightShadow",
        Shape = Enum.PartType.Ball,
        Material = Enum.Material.SmoothPlastic,
        Color = Color3.fromRGB(4, 6, 12),
        Transparency = 0.42,
        Size = Vector3.new(d * 1.015, d * 1.015, d * 1.015),
        Position = def.OrbitCenter,
        Parent = model
    })

    local atmoPart = nil
    if def.HasAtmosphere then
        atmoPart = Util.CreatePart({
            Name = "AtmosphereGlow",
            Shape = Enum.PartType.Ball,
            Material = Enum.Material.ForceField,
            Color = def.AtmosphereColor or def.Color,
            Transparency = 0.62,
            Size = Vector3.new(d * 1.07, d * 1.07, d * 1.07),
            Position = def.OrbitCenter,
            Parent = model
        })
    end

    local details = {}
    local clouds = {}
    local cityLights = {}
    local rings = {}
    local rng = Random.new(CONFIG.SeedUniverse + #self.BodyRuntimes * 101)

    -- Detalhes específicos de cada tipo de planeta
    if def.Type == "Terra" then
        -- Continentes verdes/marrons semi-embutidos
        for i = 1, 14 do
            local dir = Vector3.new(rng:NextNumber(-1, 1), rng:NextNumber(-0.75, 0.75), rng:NextNumber(-1, 1)).Unit
            local cSize = def.Radius * rng:NextNumber(0.38, 0.62)
            local cont = Util.CreatePart({
                Name = "Continent_" .. i,
                Shape = Enum.PartType.Ball,
                Material = Enum.Material.Grass,
                Color = (i % 3 == 0) and Color3.fromRGB(135, 110, 68) or def.SecondaryColor,
                Size = Vector3.new(cSize, cSize * 0.65, cSize),
                Parent = model
            })
            table.insert(details, { Part = cont, LocalPos = dir * (def.Radius * 0.82), LocalRot = CFrame.lookAt(Vector3.zero, dir) })
        end
        -- Camada de nuvens girando em velocidade diferente
        for i = 1, 12 do
            local dir = Vector3.new(rng:NextNumber(-1, 1), rng:NextNumber(-0.85, 0.85), rng:NextNumber(-1, 1)).Unit
            local clSize = def.Radius * rng:NextNumber(0.32, 0.55)
            local cloud = Util.CreatePart({
                Name = "Cloud_" .. i,
                Shape = Enum.PartType.Ball,
                Material = Enum.Material.SmoothPlastic,
                Color = Color3.fromRGB(245, 250, 255),
                Transparency = 0.38,
                Size = Vector3.new(clSize * 1.3, clSize * 0.25, clSize),
                Parent = model
            })
            table.insert(clouds, { Part = cloud, Dir = dir, AngleOffset = i * 0.52 })
        end
        -- Luzes de cidade no lado noturno (calculado por produto escalar com o Sol)
        for i = 1, 22 do
            local dir = Vector3.new(rng:NextNumber(-1, 1), rng:NextNumber(-0.7, 0.7), rng:NextNumber(-1, 1)).Unit
            local lightPart = Util.CreatePart({
                Name = "CityLight_" .. i,
                Shape = Enum.PartType.Ball,
                Material = Enum.Material.Neon,
                Color = Color3.fromRGB(255, 215, 110),
                Size = Vector3.new(18, 18, 18),
                Transparency = 1,
                Parent = model
            })
            table.insert(cityLights, { Part = lightPart, Dir = dir, RadiusOffset = def.Radius * 1.005 })
        end
    elseif def.Type == "Mars" then
        -- Calotas polares brancas no topo e na base
        for _, signY in ipairs({ 1, -1 }) do
            local cap = Util.CreatePart({
                Name = "PolarCap",
                Shape = Enum.PartType.Ball,
                Material = Enum.Material.Ice,
                Color = def.SecondaryColor,
                Size = Vector3.new(def.Radius * 1.1, def.Radius * 0.45, def.Radius * 1.1),
                Parent = model
            })
            table.insert(details, { Part = cap, LocalPos = Vector3.new(0, signY * def.Radius * 0.84, 0), LocalRot = CFrame.identity })
        end
    elseif def.Type == "GasGiant" then
        -- Bandas coloridas achatadas e anéis duplos inclinados
        for i = -2, 2 do
            if i ~= 0 then
                local band = Util.CreatePart({
                    Name = "GasBand_" .. i,
                    Shape = Enum.PartType.Cylinder,
                    Material = Enum.Material.SmoothPlastic,
                    Color = (i % 2 == 0) and def.SecondaryColor or Color3.fromRGB(235, 195, 145),
                    Size = Vector3.new(def.Radius * 0.22, d * 1.012, d * 1.012),
                    Parent = model
                })
                table.insert(details, {
                    Part = band,
                    LocalPos = Vector3.new(0, i * (def.Radius * 0.28), 0),
                    LocalRot = CFrame.Angles(0, 0, math.rad(90))
                })
            end
        end
        -- Anéis em 2 camadas de rochas e poeira
        local ringCount = (Cosmos.QualityLevel == 1) and 22 or 40
        for layer = 1, 2 do
            local rRad = (layer == 1) and def.RingInner or def.RingOuter
            local rCol = (layer == 1) and Color3.fromRGB(225, 195, 150) or Color3.fromRGB(165, 145, 125)
            for j = 1, ringCount do
                local ang = (j / ringCount) * math.pi * 2
                local seg = Util.CreatePart({
                    Name = "RingSeg_" .. layer .. "_" .. j,
                    Material = (layer == 1) and Enum.Material.Rock or Enum.Material.Sand,
                    Color = rCol,
                    Transparency = (layer == 1) and 0.15 or 0.38,
                    Size = Vector3.new(65, 14, (2 * math.pi * rRad / ringCount) * 0.92),
                    Parent = model
                })
                table.insert(rings, { Part = seg, Radius = rRad, Angle = ang, Speed = (layer == 1) and 0.08 or 0.045 })
            end
        end
    elseif def.Type == "Ice" then
        -- Cristais gigantes translúcidos na superfície
        for i = 1, 12 do
            local dir = Vector3.new(rng:NextNumber(-1, 1), rng:NextNumber(-1, 1), rng:NextNumber(-1, 1)).Unit
            local crys = Util.CreatePart({
                Name = "IceCrystal_" .. i,
                Material = Enum.Material.Neon,
                Color = def.SecondaryColor,
                Transparency = 0.25,
                Size = Vector3.new(36, 130, 36),
                Parent = model
            })
            table.insert(details, {
                Part = crys,
                LocalPos = dir * (def.Radius * 0.98),
                LocalRot = CFrame.lookAt(Vector3.zero, dir) * CFrame.Angles(math.rad(90), 0, 0)
            })
        end
    elseif def.Type == "Lava" then
        -- Fissuras tectônicas de magma Neon pulsantes
        for i = 1, 14 do
            local dir = Vector3.new(rng:NextNumber(-1, 1), rng:NextNumber(-1, 1), rng:NextNumber(-1, 1)).Unit
            local crack = Util.CreatePart({
                Name = "LavaCrack_" .. i,
                Shape = Enum.PartType.Ball,
                Material = Enum.Material.Neon,
                Color = def.SecondaryColor,
                Size = Vector3.new(def.Radius * 0.55, def.Radius * 0.14, def.Radius * 0.22),
                Parent = model
            })
            table.insert(details, {
                Part = crack,
                LocalPos = dir * (def.Radius * 0.96),
                LocalRot = CFrame.lookAt(Vector3.zero, dir),
                IsLava = true
            })
        end
    end

    local runtime = {
        Def = def,
        Model = model,
        Root = root,
        Shadow = shadowPart,
        Atmosphere = atmoPart,
        Details = details,
        Clouds = clouds,
        CityLights = cityLights,
        Rings = rings,
        Moons = {},
        Position = def.OrbitCenter,
        Angle = def.Phase or 0,
        RotAngle = 0,
        CloudAngle = 0,
    }

    -- Construir Luas Orbitais com Crateras
    if def.Moons then
        for _, mDef in ipairs(def.Moons) do
            local mModel = Instance.new("Model")
            mModel.Name = mDef.Id
            mModel.Parent = self.Folder
            local md = mDef.Radius * 2
            local mRoot = Util.CreatePart({
                Name = "MoonCore",
                Shape = Enum.PartType.Ball,
                Material = Enum.Material.Slate,
                Color = mDef.Color,
                Size = Vector3.new(md, md, md),
                Position = def.OrbitCenter + Vector3.new(mDef.OrbitRadius, 0, 0),
                Parent = mModel
            })
            mModel.PrimaryPart = mRoot

            local mCraterList = {}
            for c = 1, 8 do
                local cDir = Vector3.new(rng:NextNumber(-1, 1), rng:NextNumber(-1, 1), rng:NextNumber(-1, 1)).Unit
                local cRad = mDef.Radius * rng:NextNumber(0.22, 0.36)
                local crater = Util.CreatePart({
                    Name = "Crater_" .. c,
                    Shape = Enum.PartType.Ball,
                    Material = Enum.Material.Rock,
                    Color = mDef.CraterColor,
                    Size = Vector3.new(cRad, cRad * 0.45, cRad),
                    Parent = mModel
                })
                table.insert(mCraterList, { Part = crater, LocalPos = cDir * (mDef.Radius * 0.91), LocalRot = CFrame.lookAt(Vector3.zero, cDir) })
            end

            local moonRuntime = {
                Def = mDef,
                IsMoon = true,
                ParentBody = runtime,
                Model = mModel,
                Root = mRoot,
                Craters = mCraterList,
                Position = mRoot.Position,
                Angle = mDef.Phase or 0,
            }
            table.insert(runtime.Moons, moonRuntime)
            self.BodyMap[mDef.Id] = moonRuntime
        end
    end

    table.insert(self.BodyRuntimes, runtime)
    self.BodyMap[def.Id] = runtime
end

function Universe:BuildAsteroidBelt()
    local beltFolder = Instance.new("Folder")
    beltFolder.Name = "AsteroidBelt"
    beltFolder.Parent = self.Folder

    local rng = Random.new(CONFIG.SeedUniverse + 777)
    local count = CONFIG.AsteroidCount[Cosmos.QualityLevel] or 100

    for i = 1, count do
        local ang = (i / count) * math.pi * 2 + rng:NextNumber(-0.08, 0.08)
        local dist = rng:NextNumber(CONFIG.BeltRadiusInner, CONFIG.BeltRadiusOuter)
        local yOff = rng:NextNumber(-260, 260)
        local sizeScale = rng:NextNumber(16, 68)
        local pos = CONFIG.BeltCenter + Vector3.new(math.cos(ang) * dist, yOff, math.sin(ang) * dist)

        local ast = Util.CreatePart({
            Name = "Asteroid_" .. i,
            Material = Enum.Material.Rock,
            Color = Color3.fromRGB(rng:NextInteger(95, 135), rng:NextInteger(90, 125), rng:NextInteger(85, 115)),
            Size = Vector3.new(sizeScale, sizeScale * rng:NextNumber(0.65, 1.25), sizeScale * rng:NextNumber(0.7, 1.3)),
            CFrame = CFrame.new(pos) * CFrame.Angles(rng:NextNumber(0, 6), rng:NextNumber(0, 6), 0),
            Parent = beltFolder
        })

        table.insert(self.Asteroids, {
            Part = ast,
            Angle = ang,
            Dist = dist,
            YOff = yOff,
            OrbitSpeed = rng:NextNumber(0.008, 0.022),
            RotAxis = Vector3.new(rng:NextNumber(-1, 1), rng:NextNumber(-1, 1), rng:NextNumber(-1, 1)).Unit,
            RotAngle = 0,
        })
    end
end

function Universe:BuildStarsAndNebulas()
    local starFolder = Instance.new("Folder")
    starFolder.Name = "StarfieldShell"
    starFolder.Parent = self.Folder
    self.StarShellFolder = starFolder

    local rng = Random.new(CONFIG.SeedUniverse + 999)
    local starColors = {
        Color3.fromRGB(255, 255, 255),
        Color3.fromRGB(175, 215, 255),
        Color3.fromRGB(255, 225, 170),
    }

    local maxStars = CONFIG.StarCount[3]
    for i = 1, maxStars do
        -- Distribuição uniforme em esfera
        local u = rng:NextNumber(-1, 1)
        local theta = rng:NextNumber(0, math.pi * 2)
        local rXY = math.sqrt(math.max(0, 1 - u * u))
        local dir = Vector3.new(rXY * math.cos(theta), u, rXY * math.sin(theta)).Unit
        local sz = rng:NextNumber(3.5, 9.5)

        local st = Util.CreatePart({
            Name = "Star_" .. i,
            Shape = Enum.PartType.Ball,
            Material = Enum.Material.Neon,
            Color = starColors[(i % 3) + 1],
            Transparency = 1,
            Size = Vector3.new(sz, sz, sz),
            Position = dir * CONFIG.StarShellRadius,
            Parent = starFolder
        })
        table.insert(self.StarParts, {
            Part = st,
            Dir = dir,
            BaseSize = sz,
            TwinkleOffset = rng:NextNumber(0, math.pi * 2),
        })
    end

    -- Nebulosas distantes em tons roxo/azul/rosa
    local nebColors = {
        Color3.fromRGB(155, 55, 235),
        Color3.fromRGB(55, 145, 255),
        Color3.fromRGB(245, 75, 165),
    }
    for n = 1, CONFIG.NebulaCount do
        local nAng = (n / CONFIG.NebulaCount) * math.pi * 2
        local nCenter = CONFIG.UniverseCenter + Vector3.new(math.cos(nAng) * 14500, rng:NextNumber(-2500, 3500), math.sin(nAng) * 14500)
        local col = nebColors[(n % #nebColors) + 1]
        for c = 1, 5 do
            local offset = Vector3.new(rng:NextNumber(-900, 900), rng:NextNumber(-450, 450), rng:NextNumber(-900, 900))
            local cloud = Util.CreatePart({
                Name = "NebulaCloud_" .. n .. "_" .. c,
                Shape = Enum.PartType.Ball,
                Material = Enum.Material.Neon,
                Color = col,
                Transparency = 0.88,
                Size = Vector3.new(1650, 950, 1450),
                Position = nCenter + offset,
                Parent = self.Folder
            })
            table.insert(self.Nebulas, cloud)
        end
    end
end

function Universe:BuildComet()
    local cometModel = Instance.new("Model")
    cometModel.Name = "HalleyComet"
    cometModel.Parent = self.Folder

    local head = Util.CreatePart({
        Name = "CometHead",
        Shape = Enum.PartType.Ball,
        Material = Enum.Material.Neon,
        Color = Color3.fromRGB(195, 245, 255),
        Size = Vector3.new(42, 42, 42),
        Transparency = 1,
        Position = Vector3.new(0, -5000, 0),
        Parent = cometModel
    })

    local a0 = Instance.new("Attachment")
    a0.Position = Vector3.new(0, 16, 0)
    a0.Parent = head
    local a1 = Instance.new("Attachment")
    a1.Position = Vector3.new(0, -16, 0)
    a1.Parent = head

    local trail = Instance.new("Trail")
    trail.Attachment0 = a0
    trail.Attachment1 = a1
    trail.Lifetime = 2.6
    trail.Color = ColorSequence.new(Color3.fromRGB(255, 250, 180), Color3.fromRGB(80, 195, 255))
    trail.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.1),
        NumberSequenceKeypoint.new(1, 1.0)
    })
    trail.Enabled = false
    trail.Parent = head

    self.Comet = {
        Head = head,
        Trail = trail,
        Active = false,
        Progress = 0,
        StartPos = Vector3.zero,
        EndPos = Vector3.zero,
    }
end

function Universe:Init()
    local f = Instance.new("Folder")
    f.Name = "SolarSystem"
    f.Parent = WorldFolder
    self.Folder = f
    self.Maid:Add(f)

    self:BuildSun()
    for _, def in ipairs(BODIES) do
        self:BuildPlanet(def)
    end
    self:BuildAsteroidBelt()
    self:BuildStarsAndNebulas()
    self:BuildComet()
end

function Universe:GetBodyPosition(idOrName)
    local rt = self.BodyMap[idOrName]
    if rt then return rt.Position end
    for _, b in ipairs(self.BodyRuntimes) do
        if b.Def.Name == idOrName or b.Def.Id == idOrName then
            return b.Position
        end
        for _, m in ipairs(b.Moons) do
            if m.Def.Name == idOrName or m.Def.Id == idOrName then
                return m.Position
            end
        end
    end
    return nil
end

function Universe:GetAllBodiesList()
    local list = {}
    for _, b in ipairs(self.BodyRuntimes) do
        table.insert(list, b)
        for _, m in ipairs(b.Moons) do
            table.insert(list, m)
        end
    end
    return list
end

function Universe:GetNearestBody(pos)
    local best = nil
    local bestSurfaceDist = math.huge
    for _, b in ipairs(self:GetAllBodiesList()) do
        local d = (b.Position - pos).Magnitude - b.Def.Radius
        if d < bestSurfaceDist then
            bestSurfaceDist = d
            best = b
        end
    end
    return best, bestSurfaceDist
end

function Universe:GetBodiesSortedByDistance(pos)
    local list = self:GetAllBodiesList()
    table.sort(list, function(a, b)
        return (a.Position - pos).Magnitude < (b.Position - pos).Magnitude
    end)
    return list
end

function Universe:Update(dt)
    self.SimTime = self.SimTime + dt
    local t = self.SimTime
    local sunPos = CONFIG.SunPosition

    -- 1. Pulsar Corona Solar e girar raios solares
    if self.CoronaInner and self.CoronaOuter then
        self.CoronaInner.Transparency = 0.50 + math.sin(t * 2.1) * 0.12
        self.CoronaOuter.Transparency = 0.74 + math.cos(t * 1.5) * 0.10
    end
    for _, r in ipairs(self.SunRays) do
        r.A1 = r.A1 + dt * r.Speed
        r.Part.CFrame = CFrame.new(sunPos) * CFrame.Angles(r.A1, r.A2, t * 0.04)
    end

    -- 2. Atualizar órbitas elípticas, rotações, nuvens, luzes de cidade e sombras dos Planetas
    for _, b in ipairs(self.BodyRuntimes) do
        local def = b.Def
        b.Angle = b.Angle + dt * def.OrbitSpeed
        b.RotAngle = b.RotAngle + dt * def.RotationSpeed
        b.CloudAngle = b.CloudAngle + dt * (def.RotationSpeed * 1.45)

        local a = def.SemiMajor
        local e = def.Eccentricity or 0
        local bAxis = a * math.sqrt(math.max(0.1, 1 - e * e))
        local incRad = math.rad(def.Inclination or 0)

        local ox = math.cos(b.Angle) * a
        local oz = math.sin(b.Angle) * bAxis
        local oy = math.sin(b.Angle) * a * math.sin(incRad) * 0.25

        local newPos = def.OrbitCenter + Vector3.new(ox, oy, oz)
        b.Position = newPos

        local bodyCF = CFrame.new(newPos) * CFrame.Angles(incRad * 0.3, b.RotAngle, 0)
        b.Root.CFrame = bodyCF

        local toSun = (sunPos - newPos).Unit
        if b.Shadow then
            b.Shadow.Position = newPos - toSun * (def.Radius * 0.06)
        end
        if b.Atmosphere then
            b.Atmosphere.Position = newPos
        end

        for _, det in ipairs(b.Details) do
            det.Part.CFrame = bodyCF * CFrame.new(det.LocalPos) * det.LocalRot
            if det.IsLava then
                local pulse = 0.5 + 0.5 * math.sin(t * 3.2)
                det.Part.Color = Color3.fromRGB(255, math.floor(75 + 90 * pulse), 15)
            end
        end

        local cloudCF = CFrame.new(newPos) * CFrame.Angles(0, b.CloudAngle, 0)
        for _, cl in ipairs(b.Clouds) do
            local cPos = cloudCF:PointToWorldSpace(cl.Dir * (def.Radius * 1.025))
            cl.Part.CFrame = CFrame.lookAt(cPos, newPos) * CFrame.Angles(math.rad(90), 0, 0)
        end

        -- Luzes de cidade no hemisfério oposto ao Sol (produto escalar < -0.08)
        for _, clight in ipairs(b.CityLights) do
            local worldDir = bodyCF:VectorToWorldSpace(clight.Dir)
            local dotSun = worldDir:Dot(toSun)
            if dotSun < -0.08 then
                clight.Part.Position = newPos + worldDir * clight.RadiusOffset
                clight.Part.Transparency = Util.Clamp(1 - (-dotSun * 1.35), 0.05, 0.9)
            else
                clight.Part.Transparency = 1
            end
        end

        -- Anéis planetários
        if #b.Rings > 0 then
            local ringPlane = CFrame.new(newPos) * CFrame.Angles(math.rad(22), 0, math.rad(14))
            for _, rg in ipairs(b.Rings) do
                rg.Angle = rg.Angle + dt * rg.Speed
                local rx = math.cos(rg.Angle) * rg.Radius
                local rz = math.sin(rg.Angle) * rg.Radius
                local rPos = ringPlane:PointToWorldSpace(Vector3.new(rx, 0, rz))
                rg.Part.CFrame = CFrame.lookAt(rPos, newPos) * CFrame.Angles(0, math.rad(90), 0)
            end
        end

        -- Luas do planeta
        for _, m in ipairs(b.Moons) do
            local mDef = m.Def
            m.Angle = m.Angle + dt * mDef.OrbitSpeed
            local mInc = math.rad(mDef.Inclination or 0)
            local mx = math.cos(m.Angle) * mDef.OrbitRadius
            local mz = math.sin(m.Angle) * mDef.OrbitRadius
            local my = math.sin(m.Angle) * mDef.OrbitRadius * math.sin(mInc) * 0.35
            local mPos = newPos + Vector3.new(mx, my, mz)
            m.Position = mPos
            local mCF = CFrame.new(mPos) * CFrame.Angles(0, m.Angle, 0)
            m.Root.CFrame = mCF
            for _, cr in ipairs(m.Craters) do
                cr.Part.CFrame = mCF * CFrame.new(cr.LocalPos) * cr.LocalRot
            end
        end
    end

    -- 3. Cinturão de Asteroides (atualizar em lote para alta performance)
    local maxAst = CONFIG.AsteroidCount[Cosmos.QualityLevel] or 100
    for i = 1, #self.Asteroids do
        local ast = self.Asteroids[i]
        if i <= maxAst then
            ast.Angle = ast.Angle + dt * ast.OrbitSpeed
            ast.RotAngle = ast.RotAngle + dt * 0.35
            local ax = math.cos(ast.Angle) * ast.Dist
            local az = math.sin(ast.Angle) * ast.Dist
            local pos = CONFIG.BeltCenter + Vector3.new(ax, ast.YOff, az)
            ast.Part.CFrame = CFrame.new(pos) * CFrame.fromAxisAngle(ast.RotAxis, ast.RotAngle)
        end
    end

    -- 4. Casca Esférica de Estrelas acompanhando a Câmera e Cintilação em lotes
    local camPos = Camera and Camera.CFrame.Position or Vector3.zero
    local sf = Cosmos.State.SpaceFactor
    local activeStarLimit = CONFIG.StarCount[Cosmos.QualityLevel] or 400
    local hyperStretch = (Cosmos.State.Flying and Cosmos.State.FlightMode == 3 and sf > 0.4)

    for i = 1, #self.StarParts do
        local st = self.StarParts[i]
        if i <= activeStarLimit and sf > 0.08 then
            st.Part.Position = camPos + st.Dir * CONFIG.StarShellRadius
            if (i + Cosmos.FrameCount) % 6 == 0 then
                local twinkle = 0.15 * math.sin(t * 3.8 + st.TwinkleOffset)
                st.Part.Transparency = Util.Clamp(1 - sf + twinkle, 0.02, 1)
            end
            if hyperStretch then
                st.Part.Size = Vector3.new(st.BaseSize * 0.7, st.BaseSize * 0.7, st.BaseSize * 12)
                st.Part.CFrame = CFrame.lookAt(st.Part.Position, st.Part.Position + Camera.CFrame.LookVector)
            else
                st.Part.Size = Vector3.new(st.BaseSize, st.BaseSize, st.BaseSize)
            end
        else
            st.Part.Transparency = 1
        end
    end

    -- 5. Cometa periódico cruzando o sistema solar
    if self.Comet then
        if not self.Comet.Active then
            self.CometTimer = self.CometTimer - dt
            if self.CometTimer <= 0 then
                self.Comet.Active = true
                self.Comet.Progress = 0
                self.Comet.StartPos = camPos + Vector3.new(-2800, 1400, -2400)
                self.Comet.EndPos = camPos + Vector3.new(2800, 900, 2200)
                self.Comet.Head.Transparency = 0
                self.Comet.Trail.Enabled = true
                self.CometTimer = 28
            end
        else
            self.Comet.Progress = self.Comet.Progress + dt * 0.14
            if self.Comet.Progress >= 1 then
                self.Comet.Active = false
                self.Comet.Head.Transparency = 1
                self.Comet.Trail.Enabled = false
            else
                local cPos = self.Comet.StartPos:Lerp(self.Comet.EndPos, self.Comet.Progress)
                self.Comet.Head.CFrame = CFrame.lookAt(cPos, self.Comet.EndPos)
            end
        end
    end

    -- Atualizar corpo mais próximo para o HUD e Sistema de Gravidade
    local _, hrp = Util.GetCharacter()
    local refPos = hrp and hrp.Position or camPos
    local nearest, surfDist = self:GetNearestBody(refPos)
    Cosmos.State.NearestBody = nearest
    Cosmos.State.NearestDist = surfDist
    if nearest and surfDist < 420 and not nearest.IsMoon then
        if not Cosmos.State.PlanetsVisited[nearest.Def.Id] then
            Cosmos.State.PlanetsVisited[nearest.Def.Id] = true
            if Cosmos.Modules.Missions then
                Cosmos.Modules.Missions:NotifyPlanetVisited(nearest.Def.Name)
            end
        end
    end
end

function Universe:Destroy()
    self.Maid:Clean()
end

--====================================================================================================
-- [SEÇÃO 07] MÓDULO 3: ATMOSPHERE / SPACE TRANSITION (CÉU -> ESPAÇO E CALOR DE REENTRADA)
--====================================================================================================
local SpaceTransition = {
    Maid = Maid.new(),
    SavedLighting = {},
    AtmoInst = nil,
    BloomInst = nil,
    CCInst = nil,
    ReentryPart = nil,
    ReentryIntensity = 0,
}
Util.RegisterModule("SpaceTransition", SpaceTransition)

function SpaceTransition:Init()
    local L = Services.Lighting
    self.SavedLighting = {
        ClockTime = L.ClockTime,
        Brightness = L.Brightness,
        Ambient = L.Ambient,
        OutdoorAmbient = L.OutdoorAmbient,
        ExposureCompensation = L.ExposureCompensation,
        FogEnd = L.FogEnd,
        Gravity = Services.Workspace.Gravity,
    }

    local atmo = Instance.new("Atmosphere")
    atmo.Name = "__CosmosAtmosphere"
    atmo.Density = 0.32
    atmo.Haze = 1.2
    atmo.Glare = 0.25
    atmo.Color = Color3.fromRGB(140, 195, 255)
    atmo.Decay = Color3.fromRGB(90, 130, 195)
    atmo.Parent = L
    self.AtmoInst = atmo
    self.Maid:Add(atmo)

    local bloom = Instance.new("BloomEffect")
    bloom.Name = "__CosmosBloom"
    bloom.Intensity = 0.4
    bloom.Size = 24
    bloom.Threshold = 0.95
    bloom.Parent = L
    self.BloomInst = bloom
    self.Maid:Add(bloom)

    local cc = Instance.new("ColorCorrectionEffect")
    cc.Name = "__CosmosCC"
    cc.Contrast = 0.08
    cc.Saturation = 0.12
    cc.TintColor = Color3.fromRGB(255, 255, 255)
    cc.Parent = L
    self.CCInst = cc
    self.Maid:Add(cc)

    -- Cone visual de plasma para reentrada atmosférica
    local reentry = Util.CreatePart({
        Name = "ReentryHeatShield",
        Shape = Enum.PartType.Ball,
        Material = Enum.Material.Neon,
        Color = Color3.fromRGB(255, 95, 20),
        Transparency = 1,
        Size = Vector3.new(11, 11, 14),
        Parent = WorldFolder
    })
    self.ReentryPart = reentry
    self.Maid:Add(reentry)
end

function SpaceTransition:Update(dt)
    local _, hrp = Util.GetCharacter()
    local pos = hrp and hrp.Position or (Camera and Camera.CFrame.Position or Vector3.zero)
    local alt = math.max(0, pos.Y)
    Cosmos.State.Altitude = alt

    local rawFactor = Util.Clamp((alt - CONFIG.AltStart) / (CONFIG.AltFull - CONFIG.AltStart), 0, 1)
    -- Se estiver muito próximo de um planeta com atmosfera, reduz spaceFactor localmente
    local near = Cosmos.State.NearestBody
    local nearDist = Cosmos.State.NearestDist
    local inPlanetAtmo = false
    if near and near.Def.HasAtmosphere and nearDist < 260 then
        local atmoBlend = Util.Clamp(nearDist / 260, 0, 1)
        rawFactor = rawFactor * (0.25 + 0.75 * atmoBlend)
        inPlanetAtmo = true
    end

    Cosmos.State.SpaceFactor = Util.Lerp(Cosmos.State.SpaceFactor, rawFactor, dt * 3.5)
    local sf = Cosmos.State.SpaceFactor
    Cosmos.State.InSpace = (sf > 0.65)

    -- Consumo e Regeneração de Oxigênio
    if sf > 0.55 and not inPlanetAtmo then
        Cosmos.State.Oxygen = math.max(0, Cosmos.State.Oxygen - CONFIG.Oxygen.DrainRate * dt)
        if Cosmos.State.Oxygen <= 0 then
            Cosmos.State.Health = math.max(0, Cosmos.State.Health - CONFIG.Oxygen.ZeroDamageRate * dt)
        end
    else
        Cosmos.State.Oxygen = math.min(Cosmos.State.MaxOxygen, Cosmos.State.Oxygen + CONFIG.Oxygen.RegenRate * dt)
    end

    -- Interpolação de Lighting em 3 fases (0-25% Céu, 25-60% Crepúsculo Orbital, 60-100% Vácuo Profundo)
    local L = Services.Lighting
    L.ClockTime = Util.Lerp(14.0, 0.0, Util.SmoothStep(0.15, 0.85, sf))
    L.Brightness = Util.Lerp(2.2, 0.85, sf)
    L.Ambient = Util.LerpColor(Color3.fromRGB(110, 130, 150), Color3.fromRGB(16, 20, 30), sf)
    L.OutdoorAmbient = Util.LerpColor(Color3.fromRGB(130, 150, 175), Color3.fromRGB(10, 14, 22), sf)

    if self.AtmoInst then
        self.AtmoInst.Density = Util.Lerp(0.30, 0.0, sf)
        self.AtmoInst.Haze = Util.Lerp(1.2, 0.0, sf)
        if sf > 0.25 and sf < 0.65 then
            self.AtmoInst.Color = Color3.fromRGB(255, 130, 85)
        else
            self.AtmoInst.Color = Color3.fromRGB(130, 190, 255)
        end
    end

    if self.BloomInst then
        self.BloomInst.Intensity = Util.Lerp(0.4, 1.15, sf)
    end

    -- Efeito de Calor de Reentrada (Reentry Plasma) ao entrar rápido na atmosfera
    local spd = Cosmos.State.Speed
    local enteringAtmo = ((alt > CONFIG.AltStart and alt < CONFIG.AltFull) or inPlanetAtmo) and (spd > 240)
    if enteringAtmo and hrp then
        local targetHeat = Util.Clamp((spd - 240) / 350, 0, 1)
        self.ReentryIntensity = Util.Lerp(self.ReentryIntensity, targetHeat, dt * 6)
        self.ReentryPart.Transparency = 1 - (self.ReentryIntensity * 0.68)
        local velDir = (hrp.AssemblyLinearVelocity.Magnitude > 5) and hrp.AssemblyLinearVelocity.Unit or hrp.CFrame.LookVector
        self.ReentryPart.CFrame = CFrame.lookAt(hrp.Position + velDir * 3.5, hrp.Position + velDir * 10)
        CameraFX:Shake(self.ReentryIntensity * 0.22, 8)
        if self.CCInst then
            self.CCInst.TintColor = Util.LerpColor(Color3.new(1, 1, 1), Color3.fromRGB(255, 195, 165), self.ReentryIntensity)
        end
    else
        self.ReentryIntensity = Util.Lerp(self.ReentryIntensity, 0, dt * 6)
        if self.ReentryPart then
            self.ReentryPart.Transparency = 1
        end
        if self.CCInst then
            self.CCInst.TintColor = Color3.new(1, 1, 1)
        end
    end

    -- Notificar missão de alcançar o espaço
    if sf > 0.92 and Cosmos.Modules.Missions then
        Cosmos.Modules.Missions:NotifyProgress("m_space", 1)
    end
end

function SpaceTransition:Destroy()
    local L = Services.Lighting
    for k, v in pairs(self.SavedLighting) do
        pcall(function()
            if k == "Gravity" then
                Services.Workspace.Gravity = v
            else
                L[k] = v
            end
        end)
    end
    self.Maid:Clean()
end

--====================================================================================================
-- [SEÇÃO 08] MÓDULO 4: FLIGHT (VOO SUPERMAN COMPLETO, POSE, BANKING, WIND LINES, SONIC BOOM)
--====================================================================================================
local Flight = {
    Maid = Maid.new(),
    BodyVel = nil,
    BodyGyro = nil,
    CurrentVel = Vector3.zero,
    BankAngle = 0,
    SonicTriggered = false,
    WindLines = {},
    ShockwaveRing = nil,
    ShockwaveScale = 0,
    TrailInst = nil,
    TrailA0 = nil,
    TrailA1 = nil,
}
Util.RegisterModule("Flight", Flight)

function Flight:CreateWindPool()
    for i = 1, 16 do
        local wl = Util.CreatePart({
            Name = "WindLine_" .. i,
            Material = Enum.Material.Neon,
            Color = Color3.fromRGB(210, 245, 255),
            Transparency = 1,
            Size = Vector3.new(0.18, 0.18, 14),
            Parent = WorldFolder
        })
        table.insert(self.WindLines, {
            Part = wl,
            Offset = Vector3.new(math.random(-14, 14), math.random(-10, 10), math.random(-25, 5)),
            ZProgress = math.random() * 40,
        })
        self.Maid:Add(wl)
    end

    self.ShockwaveRing = Util.CreatePart({
        Name = "SonicShockwave",
        Shape = Enum.PartType.Cylinder,
        Material = Enum.Material.Neon,
        Color = Color3.fromRGB(165, 240, 255),
        Transparency = 1,
        Size = Vector3.new(0.8, 4, 4),
        Parent = WorldFolder
    })
    self.Maid:Add(self.ShockwaveRing)
end

function Flight:AttachTrail(hrp)
    if self.TrailInst and self.TrailInst.Parent == hrp then return end
    if self.TrailInst then pcall(function() self.TrailInst:Destroy() end) end

    local a0 = Instance.new("Attachment")
    a0.Position = Vector3.new(0, 1.5, 0)
    a0.Parent = hrp
    local a1 = Instance.new("Attachment")
    a1.Position = Vector3.new(0, -1.5, 0)
    a1.Parent = hrp

    local tr = Instance.new("Trail")
    tr.Attachment0 = a0
    tr.Attachment1 = a1
    tr.Lifetime = 0.55
    tr.Color = ColorSequence.new(Color3.fromRGB(0, 240, 255), Color3.fromRGB(90, 120, 255))
    tr.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.15),
        NumberSequenceKeypoint.new(1, 1.0)
    })
    tr.Enabled = false
    tr.Parent = hrp

    self.TrailInst = tr
    self.TrailA0 = a0
    self.TrailA1 = a1
end

function Flight:Init()
    self:CreateWindPool()
end

function Flight:Toggle(forceState)
    local nextState = (forceState ~= nil) and forceState or (not Cosmos.State.Flying)
    if nextState and Cosmos.State.WalkingOnPlanet and Cosmos.Modules.PlanetWalk then
        Cosmos.Modules.PlanetWalk:Disengage()
    end
    Cosmos.State.Flying = nextState

    local _, hrp, hum = Util.GetCharacter()
    if nextState and hrp and hum then
        hum.PlatformStand = true
        self:EnsureMovers(hrp)
        self:AttachTrail(hrp)
        if self.TrailInst then self.TrailInst.Enabled = true end
        Audio:Play("UIClick", 1.2, 0.8)
    else
        self:CleanupMovers()
        if hum then hum.PlatformStand = false end
        if self.TrailInst then self.TrailInst.Enabled = false end
        CameraFX:SetRoll(0)
        for _, wl in ipairs(self.WindLines) do
            wl.Part.Transparency = 1
        end
    end
end

function Flight:EnsureMovers(hrp)
    if not self.BodyVel or self.BodyVel.Parent ~= hrp then
        if self.BodyVel then pcall(function() self.BodyVel:Destroy() end) end
        local bv = Instance.new("BodyVelocity")
        bv.Name = "__CosmosFlightBV"
        bv.MaxForce = Vector3.new(1e8, 1e8, 1e8)
        bv.Velocity = Vector3.zero
        bv.Parent = hrp
        self.BodyVel = bv
    end
    if not self.BodyGyro or self.BodyGyro.Parent ~= hrp then
        if self.BodyGyro then pcall(function() self.BodyGyro:Destroy() end) end
        local bg = Instance.new("BodyGyro")
        bg.Name = "__CosmosFlightBG"
        bg.MaxTorque = Vector3.new(1e8, 1e8, 1e8)
        bg.P = 18000
        bg.D = 900
        bg.CFrame = hrp.CFrame
        bg.Parent = hrp
        self.BodyGyro = bg
    end
end

function Flight:CleanupMovers()
    if self.BodyVel then pcall(function() self.BodyVel:Destroy() end) self.BodyVel = nil end
    if self.BodyGyro then pcall(function() self.BodyGyro:Destroy() end) self.BodyGyro = nil end
    self.CurrentVel = Vector3.zero
end

function Flight:CycleFlightMode()
    if Cosmos.State.FlightMode == 1 then
        Cosmos.State.FlightMode = 2
    elseif Cosmos.State.FlightMode == 2 then
        if Cosmos.State.InSpace then
            Cosmos.State.FlightMode = 3
        else
            Cosmos.State.FlightMode = 1
        end
    else
        Cosmos.State.FlightMode = 1
    end
    Audio:Play("UIClick", 1.35, 0.7)
end

function Flight:Update(dt)
    local _, hrp, hum = Util.GetCharacter()
    if not hrp or not hum then return end

    if not Cosmos.State.Flying then
        Cosmos.State.Speed = hrp.AssemblyLinearVelocity.Magnitude
        Cosmos.State.Stamina = math.min(CONFIG.Flight.StaminaRegen * dt + Cosmos.State.Stamina, Cosmos.State.MaxStamina)
        return
    end

    self:EnsureMovers(hrp)
    hum.PlatformStand = true

    -- Capturar direção do analógico mobile / WASD + botões verticais
    local camCF = Camera and Camera.CFrame or hrp.CFrame
    local moveDir = hum.MoveDirection
    local touchMove = Cosmos.State.TouchInputs.MoveVector

    local forward = 0
    local right = 0
    local up = 0

    if touchMove.Magnitude > 0.05 then
        right = touchMove.X
        forward = -touchMove.Y
    elseif moveDir.Magnitude > 0.05 then
        local localMove = camCF:VectorToObjectSpace(moveDir)
        right = localMove.X
        forward = -localMove.Z
    end

    if Services.UserInputService:IsKeyDown(Enum.KeyCode.Space) or Cosmos.State.TouchInputs.Ascend then
        up = up + 1
    end
    if Services.UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) or Cosmos.State.TouchInputs.Descend then
        up = up - 1
    end

    local isShift = Services.UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) or Cosmos.State.TouchInputs.Boost
    if isShift and Cosmos.State.FlightMode == 1 then
        Cosmos.State.FlightMode = 2
    end
    if Cosmos.State.FlightMode == 3 and not Cosmos.State.InSpace then
        Cosmos.State.FlightMode = 2
    end

    -- Consumo de Stamina em Turbo/Hiper
    if Cosmos.State.FlightMode == 3 then
        Cosmos.State.Stamina = math.max(0, Cosmos.State.Stamina - CONFIG.Flight.StaminaDrainHyper * dt)
        if Cosmos.State.Stamina <= 0 then Cosmos.State.FlightMode = 1 end
    elseif Cosmos.State.FlightMode == 2 then
        Cosmos.State.Stamina = math.max(0, Cosmos.State.Stamina - CONFIG.Flight.StaminaDrainTurbo * dt)
        if Cosmos.State.Stamina <= 0 then Cosmos.State.FlightMode = 1 end
    else
        Cosmos.State.Stamina = math.min(Cosmos.State.MaxStamina, Cosmos.State.Stamina + CONFIG.Flight.StaminaRegen * dt)
    end

    local targetMaxSpeed = CONFIG.Flight.NormalSpeed
    if Cosmos.State.FlightMode == 2 then
        targetMaxSpeed = CONFIG.Flight.TurboSpeed
    elseif Cosmos.State.FlightMode == 3 then
        targetMaxSpeed = CONFIG.Flight.HyperSpeed
    end

    local wishDir = (camCF.LookVector * forward) + (camCF.RightVector * right) + (Vector3.yAxis * up)
    if wishDir.Magnitude > 0.01 then
        wishDir = wishDir.Unit
    end

    if Cosmos.State.TouchInputs.Brake then
        self.CurrentVel = self.CurrentVel:Lerp(Vector3.zero, Util.Clamp(dt * 10, 0, 1))
    elseif wishDir.Magnitude > 0.01 then
        self.CurrentVel = self.CurrentVel:Lerp(wishDir * targetMaxSpeed, Util.Clamp(dt * CONFIG.Flight.Accel, 0, 1))
    else
        self.CurrentVel = self.CurrentVel:Lerp(Vector3.zero, Util.Clamp(dt * CONFIG.Flight.Decel, 0, 1))
    end

    self.BodyVel.Velocity = self.CurrentVel
    local spd = self.CurrentVel.Magnitude
    Cosmos.State.Speed = spd

    -- Banking lateral e Pose Superman (horizontal ao voar rápido, hover vertical quando parado)
    local targetBank = Util.Clamp(-right * CONFIG.Flight.BankAngleMax, -CONFIG.Flight.BankAngleMax, CONFIG.Flight.BankAngleMax)
    self.BankAngle = Util.Lerp(self.BankAngle, targetBank, dt * 8)
    CameraFX:SetRoll(self.BankAngle * 0.45)

    if spd > 18 then
        local lookDir = self.CurrentVel.Unit
        local supermanPitch = math.rad(-82 * Util.Clamp(spd / CONFIG.Flight.NormalSpeed, 0.25, 1))
        self.BodyGyro.CFrame = CFrame.lookAt(hrp.Position, hrp.Position + lookDir)
            * CFrame.Angles(supermanPitch, 0, math.rad(self.BankAngle))
    else
        local flatLook = Vector3.new(camCF.LookVector.X, 0, camCF.LookVector.Z)
        if flatLook.Magnitude < 0.01 then flatLook = Vector3.zAxis end
        self.BodyGyro.CFrame = CFrame.lookAt(hrp.Position, hrp.Position + flatLook.Unit)
    end

    -- Estrondo Sônico (Sonic Boom) ao cruzar velocidade limite
    if spd >= CONFIG.Flight.SonicBoomSpeed and not self.SonicTriggered then
        self.SonicTriggered = true
        self.ShockwaveScale = 0.05
        Audio:Play("SonicBoom", 1.0, 1.0)
        CameraFX:Shake(0.95, 5.5)
        CameraFX:Flash(Color3.fromRGB(165, 240, 255), 0.55)
        if Cosmos.Modules.Missions then
            Cosmos.Modules.Missions:UnlockAchievement("a_sonic")
        end
    elseif spd < CONFIG.Flight.SonicBoomSpeed * 0.75 then
        self.SonicTriggered = false
    end

    -- Atualizar Onda de Choque Sônica
    if self.ShockwaveScale > 0 and self.ShockwaveRing then
        self.ShockwaveScale = self.ShockwaveScale + dt * 3.2
        if self.ShockwaveScale >= 1 then
            self.ShockwaveScale = 0
            self.ShockwaveRing.Transparency = 1
        else
            local diam = Util.Lerp(8, 95, self.ShockwaveScale)
            self.ShockwaveRing.Size = Vector3.new(1.2, diam, diam)
            self.ShockwaveRing.Transparency = self.ShockwaveScale
            self.ShockwaveRing.CFrame = hrp.CFrame * CFrame.Angles(0, 0, math.rad(90))
        end
    end

    -- Atualizar Linhas de Vento ao redor do jogador
    local showWind = (spd > 85) and (Cosmos.QualityLevel >= 2)
    for _, wl in ipairs(self.WindLines) do
        if showWind then
            wl.ZProgress = (wl.ZProgress + dt * spd * 0.45) % 42
            local localPos = Vector3.new(wl.Offset.X, wl.Offset.Y, 18 - wl.ZProgress)
            wl.Part.CFrame = hrp.CFrame * CFrame.new(localPos)
            wl.Part.Transparency = Util.Clamp(1 - (spd / 320), 0.25, 0.85)
        else
            wl.Part.Transparency = 1
        end
    end

    -- Cor do rastro de voo sincronizada com a Aura equipada
    if self.TrailInst then
        local eqAura = Cosmos.State.EquippedAura and AURAS[Cosmos.State.EquippedAura]
        if eqAura then
            self.TrailInst.Color = ColorSequence.new(eqAura.Primary, eqAura.Secondary)
        else
            self.TrailInst.Color = ColorSequence.new(Color3.fromRGB(0, 240, 255), Color3.fromRGB(90, 120, 255))
        end
    end
end

function Flight:Destroy()
    self:CleanupMovers()
    local _, _, hum = Util.GetCharacter()
    if hum then hum.PlatformStand = false end
    self.Maid:Clean()
end

--====================================================================================================
-- [SEÇÃO 09] MÓDULO 5: GRAVITY / PLANET WALK (GRAVIDADE ESFÉRICA & COLISÃO REAL EM LUAS/PLANETAS)
--====================================================================================================
local PlanetWalk = {
    Maid = Maid.new(),
    ColliderBall = nil,
    AlignGyro = nil,
    GravForce = nil,
    StepTimer = 0,
    DustPool = {},
}
Util.RegisterModule("PlanetWalk", PlanetWalk)

function PlanetWalk:Init()
    -- Esfera de colisão real que acompanha a lua/planeta atual onde o jogador pousou
    local col = Util.CreatePart({
        Name = "__CosmosWalkCollider",
        Shape = Enum.PartType.Ball,
        Transparency = 1,
        CanCollide = false,
        CanQuery = true,
        Size = Vector3.new(100, 100, 100),
        Position = Vector3.new(0, -9000, 0),
        Parent = WorldFolder
    })
    self.ColliderBall = col
    self.Maid:Add(col)

    for i = 1, 10 do
        local dp = Util.CreatePart({
            Name = "LunarDust_" .. i,
            Shape = Enum.PartType.Ball,
            Material = Enum.Material.Sand,
            Color = Color3.fromRGB(185, 190, 198),
            Transparency = 1,
            Size = Vector3.new(1.5, 1.5, 1.5),
            Parent = WorldFolder
        })
        table.insert(self.DustPool, { Part = dp, Alpha = 0, Pos = Vector3.zero, Vel = Vector3.zero })
        self.Maid:Add(dp)
    end
end

function PlanetWalk:Engage(bodyRuntime)
    if not bodyRuntime or not bodyRuntime.Def.Walkable then return end
    if Cosmos.State.Flying and Cosmos.Modules.Flight then
        Cosmos.Modules.Flight:Toggle(false)
    end

    Cosmos.State.WalkingOnPlanet = true
    Cosmos.State.WalkBody = bodyRuntime

    local d = bodyRuntime.Def.Radius * 2
    self.ColliderBall.Size = Vector3.new(d, d, d)
    self.ColliderBall.Position = bodyRuntime.Position
    self.ColliderBall.CanCollide = true

    local _, hrp, hum = Util.GetCharacter()
    if hrp and hum then
        hum.PlatformStand = false
        local normal = (hrp.Position - bodyRuntime.Position).Unit
        hrp.CFrame = CFrame.lookAlong(bodyRuntime.Position + normal * (bodyRuntime.Def.Radius + 4.5), hrp.CFrame.LookVector, normal)

        if not self.AlignGyro or self.AlignGyro.Parent ~= hrp then
            if self.AlignGyro then pcall(function() self.AlignGyro:Destroy() end) end
            local bg = Instance.new("BodyGyro")
            bg.Name = "__CosmosPlanetGyro"
            bg.MaxTorque = Vector3.new(1e7, 1e7, 1e7)
            bg.P = 14000
            bg.D = 650
            bg.CFrame = hrp.CFrame
            bg.Parent = hrp
            self.AlignGyro = bg
        end

        if not self.GravForce or self.GravForce.Parent ~= hrp then
            if self.GravForce then pcall(function() self.GravForce:Destroy() end) end
            local bf = Instance.new("BodyForce")
            bf.Name = "__CosmosPlanetForce"
            bf.Force = Vector3.zero
            bf.Parent = hrp
            self.GravForce = bf
        end
    end

    if Cosmos.Modules.Missions then
        Cosmos.Modules.Missions:NotifyProgress("m_moon", 1)
    end
    if Cosmos.Modules.HUD then
        Cosmos.Modules.HUD:Notify("POUSO CONFIRMADO", "Gravidade esférica ativa em " .. bodyRuntime.Def.Name, Color3.fromRGB(70, 255, 185))
    end
end

function PlanetWalk:Disengage()
    Cosmos.State.WalkingOnPlanet = false
    Cosmos.State.WalkBody = nil
    if self.ColliderBall then
        self.ColliderBall.CanCollide = false
        self.ColliderBall.Position = Vector3.new(0, -9000, 0)
    end
    if self.AlignGyro then pcall(function() self.AlignGyro:Destroy() end) self.AlignGyro = nil end
    if self.GravForce then pcall(function() self.GravForce:Destroy() end) self.GravForce = nil end
end

function PlanetWalk:TakeOff()
    local body = Cosmos.State.WalkBody
    self:Disengage()
    local _, hrp = Util.GetCharacter()
    if hrp and body then
        local upNormal = (hrp.Position - body.Position).Unit
        hrp.AssemblyLinearVelocity = upNormal * 85
    end
    if Cosmos.Modules.Flight then
        Cosmos.Modules.Flight:Toggle(true)
    end
end

function PlanetWalk:SpawnStepDust(pos, normal, color)
    for _, d in ipairs(self.DustPool) do
        if d.Alpha <= 0 then
            d.Alpha = 1.0
            d.Pos = pos
            d.Vel = normal * 6 + Vector3.new(math.random(-4, 4), math.random(-4, 4), math.random(-4, 4))
            d.Part.Color = color or Color3.fromRGB(185, 190, 198)
            break
        end
    end
end

function PlanetWalk:Update(dt)
    -- Atualizar partículas de poeira nos passos
    for _, d in ipairs(self.DustPool) do
        if d.Alpha > 0 then
            d.Alpha = math.max(0, d.Alpha - dt * 1.8)
            d.Pos = d.Pos + d.Vel * dt
            d.Part.Position = d.Pos
            local s = Util.Lerp(3.6, 1.0, d.Alpha)
            d.Part.Size = Vector3.new(s, s, s)
            d.Part.Transparency = 1 - (d.Alpha * 0.65)
        end
    end

    local _, hrp, hum = Util.GetCharacter()
    if not hrp or not hum then return end

    -- Auto-detecção de pouso suave quando perto de uma lua/planeta caminhável
    local near = Cosmos.State.NearestBody
    local surfDist = Cosmos.State.NearestDist
    if not Cosmos.State.WalkingOnPlanet then
        if near and near.Def.Walkable and surfDist < 14 and Cosmos.State.Speed < 160 then
            self:Engage(near)
        end
        return
    end

    local body = Cosmos.State.WalkBody
    if not body then
        self:Disengage()
        return
    end

    -- Se o jogador se afastar demais da superfície, desativa gravidade esférica
    local offset = hrp.Position - body.Position
    local distFromCenter = offset.Magnitude
    if distFromCenter > body.Def.Radius * CONFIG.Gravity.DisengageMultiplier then
        self:Disengage()
        return
    end

    -- Sincronizar colisor esférico com a órbita do corpo celeste
    local prevPos = self.ColliderBall.Position
    self.ColliderBall.Position = body.Position
    local bodyDelta = body.Position - prevPos
    if bodyDelta.Magnitude < 120 then
        hrp.CFrame = hrp.CFrame + bodyDelta
    end

    local normal = offset.Unit
    local camCF = Camera and Camera.CFrame or hrp.CFrame
    local forward = (camCF.LookVector - normal * camCF.LookVector:Dot(normal))
    if forward.Magnitude < 0.01 then
        forward = (hrp.CFrame.LookVector - normal * hrp.CFrame.LookVector:Dot(normal))
    end
    forward = forward.Unit

    if self.AlignGyro then
        self.AlignGyro.CFrame = CFrame.lookAlong(hrp.Position, forward, normal)
    end

    -- Cancelar gravidade global da Workspace e aplicar gravidade apontando para o centro da lua/planeta
    if self.GravForce then
        local mass = hrp.AssemblyMass
        local worldAntiGrav = Vector3.new(0, Services.Workspace.Gravity * mass, 0)
        local customGrav = -normal * ((body.Def.SurfaceGravity or CONFIG.Gravity.DefaultLunarGravity) * mass)
        self.GravForce.Force = worldAntiGrav + customGrav
    end

    -- Poeira lunar ao caminhar
    if hum.MoveDirection.Magnitude > 0.1 then
        self.StepTimer = self.StepTimer + dt
        if self.StepTimer >= 0.32 then
            self.StepTimer = 0
            self:SpawnStepDust(hrp.Position - normal * 2.8, normal, body.Def.Color)
        end
    end
end

function PlanetWalk:Destroy()
    self:Disengage()
    self.Maid:Clean()
end
-- CONTINUA NA PARTE 3/4

--====================================================================================================
-- PARTE 3/4: AURA RNG CINEMÁTICO, COMBAT FPS, ENEMY AI (DRONES & BOSS) & DESTRUCTIBLE PROPS
--====================================================================================================

--====================================================================================================
-- [SEÇÃO 10] MÓDULO 7: AURA RNG (SORTEIO, PITY, CINEMÁTICA, DISCO DE ACREÇÃO & VFX 3D EQUIPADOS)
--====================================================================================================
local AuraRNG = {
    Maid = Maid.new(),
    RollTimer = 0,
    SkipRequested = false,
    EquippedParts = {},
    CinematicParts = {},
    SpinAngle = 0,
}
Util.RegisterModule("AuraRNG", AuraRNG)

function AuraRNG:Init()
    -- Inicializar contadores de auras
    for _, a in ipairs(AURAS) do
        Cosmos.State.AuraCounts[a.Id] = 0
    end
end

function AuraRNG:GetTotalLuck()
    return Cosmos.State.BaseLuck + Cosmos.State.BonusLuck
end

function AuraRNG:SelectRandomAura()
    Cosmos.State.TotalRolls = Cosmos.State.TotalRolls + 1
    Cosmos.State.PityCounter = Cosmos.State.PityCounter + 1

    local luck = self:GetTotalLuck()
    local forceEpicPlus = false
    if Cosmos.State.PityCounter >= CONFIG.Aura.PityThreshold then
        forceEpicPlus = true
        Cosmos.State.PityCounter = 0
    end

    -- Percorre da aura mais rara para a mais comum testando probabilidade real ajustada por Luck
    for i = #AURAS, 1, -1 do
        local aura = AURAS[i]
        if not forceEpicPlus or aura.Tier >= 4 then
            local effectiveOdds = math.max(1.15, aura.Odds / luck)
            if math.random() * effectiveOdds <= 1.0 then
                if aura.Tier >= 4 then
                    Cosmos.State.PityCounter = 0
                end
                return aura
            end
        end
    end

    if forceEpicPlus then
        return AURAS[13] -- Garantia Épica mínima no Pity
    end
    return AURAS[math.random(1, 4)]
end

function AuraRNG:EquipAura(auraId)
    self:ClearEquippedVisuals()
    if not auraId or not AURAS[auraId] then
        Cosmos.State.EquippedAura = nil
        return
    end

    Cosmos.State.EquippedAura = auraId
    local aura = AURAS[auraId]
    local folder = Instance.new("Folder")
    folder.Name = "__CosmosEquippedAura"
    folder.Parent = WorldFolder
    self.EquippedFolder = folder

    -- Criar Anéis Energéticos Orbitais
    for r = 1, aura.Rings do
        local ring = Util.CreatePart({
            Name = "AuraRing_" .. r,
            Shape = Enum.PartType.Cylinder,
            Material = Enum.Material.Neon,
            Color = (r % 2 == 1) and aura.Primary or aura.Secondary,
            Transparency = 0.25,
            Size = Vector3.new(0.22, 6 + r * 2.2, 6 + r * 2.2),
            Parent = folder
        })
        table.insert(self.EquippedParts, { Type = "Ring", Part = ring, Index = r })
    end

    -- Criar Esferas de Energia Orbitais
    for o = 1, aura.Orbs do
        local orb = Util.CreatePart({
            Name = "AuraOrb_" .. o,
            Shape = Enum.PartType.Ball,
            Material = Enum.Material.Neon,
            Color = (o % 2 == 0) and aura.Primary or aura.Secondary,
            Transparency = 0.1,
            Size = Vector3.new(0.95, 0.95, 0.95),
            Parent = folder
        })
        table.insert(self.EquippedParts, { Type = "Orb", Part = orb, Index = o, Total = aura.Orbs })
    end

    -- Criar Pilares/Feixes de Energia Verticais
    for p = 1, aura.Pillars do
        local pil = Util.CreatePart({
            Name = "AuraPillar_" .. p,
            Material = Enum.Material.Neon,
            Color = aura.Secondary,
            Transparency = 0.45,
            Size = Vector3.new(0.35, 9.5, 0.35),
            Parent = folder
        })
        table.insert(self.EquippedParts, { Type = "Pillar", Part = pil, Index = p, Total = aura.Pillars })
    end

    -- Singularidade / Buraco Negro com Disco de Acreção para Auras Míticas e Cósmicas
    if aura.BlackHole then
        local bhCore = Util.CreatePart({
            Name = "SingularityCore",
            Shape = Enum.PartType.Ball,
            Material = Enum.Material.SmoothPlastic,
            Color = Color3.fromRGB(4, 4, 8),
            Size = Vector3.new(3.6, 3.6, 3.6),
            Parent = folder
        })
        local bhDisk = Util.CreatePart({
            Name = "AccretionDisk",
            Shape = Enum.PartType.Cylinder,
            Material = Enum.Material.Neon,
            Color = aura.Primary,
            Transparency = 0.18,
            Size = Vector3.new(0.25, 11.5, 11.5),
            Parent = folder
        })
        table.insert(self.EquippedParts, { Type = "BlackHole", Core = bhCore, Disk = bhDisk })
    end

    -- PointLight na raiz do jogador
    local _, hrp = Util.GetCharacter()
    if hrp then
        local pl = Instance.new("PointLight")
        pl.Name = "__CosmosAuraLight"
        pl.Color = aura.Primary
        pl.Range = 16 + aura.Tier * 4
        pl.Brightness = 1.8
        pl.Parent = hrp
        self.AuraLight = pl
    end
end

function AuraRNG:ClearEquippedVisuals()
    if self.EquippedFolder then
        pcall(function() self.EquippedFolder:Destroy() end)
        self.EquippedFolder = nil
    end
    if self.AuraLight then
        pcall(function() self.AuraLight:Destroy() end)
        self.AuraLight = nil
    end
    table.clear(self.EquippedParts)
end

function AuraRNG:ClearCinematicVisuals()
    for _, p in ipairs(self.CinematicParts) do
        pcall(function() p:Destroy() end)
    end
    table.clear(self.CinematicParts)
end

function AuraRNG:TriggerRoll()
    if Cosmos.State.RollingAura or self.RollTimer > 0 then return end
    Cosmos.State.RollingAura = true
    self.SkipRequested = false
    self.RollTimer = CONFIG.Aura.RollCooldown

    local chosen = self:SelectRandomAura()
    local rarity = RARITIES[chosen.Tier]

    -- Registrar progresso e inventário
    Cosmos.State.UnlockedAuras[chosen.Id] = true
    Cosmos.State.AuraCounts[chosen.Id] = (Cosmos.State.AuraCounts[chosen.Id] or 0) + 1
    if chosen.Id > Cosmos.State.BestAuraIndex then
        Cosmos.State.BestAuraIndex = chosen.Id
    end

    if Cosmos.Modules.Missions then
        Cosmos.Modules.Missions:NotifyProgress("m_aura5", 1)
        Cosmos.Modules.Missions:NotifyProgress("m_aura25", 1)
        if chosen.Tier >= 4 then Cosmos.Modules.Missions:UnlockAchievement("a_epic") end
        if chosen.Tier >= 5 then Cosmos.Modules.Missions:UnlockAchievement("a_legend") end
    end

    -- Executar cinemática de suspense e revelação
    task.spawn(function()
        Audio:Play("AuraCharge", 1.0, 0.9)
        if Cosmos.Modules.HUD then
            Cosmos.Modules.HUD:StartAuraCinematic(chosen, rarity)
        end

        -- Criar vórtice 3D temporário ao redor do jogador durante o suspense
        local _, hrp = Util.GetCharacter()
        local centerPos = hrp and hrp.Position or (Camera.CFrame.Position + Camera.CFrame.LookVector * 12)
        local chargeRing = Util.CreatePart({
            Name = "CinematicChargeRing",
            Shape = Enum.PartType.Cylinder,
            Material = Enum.Material.Neon,
            Color = rarity.Color,
            Transparency = 0.2,
            Size = Vector3.new(0.4, 22, 22),
            Position = centerPos,
            Parent = WorldFolder
        })
        table.insert(self.CinematicParts, chargeRing)

        local suspenseTime = rarity.Suspense
        local elapsed = 0
        local tickAccum = 0

        while elapsed < suspenseTime and not self.SkipRequested and Cosmos.Active do
            local dt = task.wait()
            elapsed = elapsed + dt
            tickAccum = tickAccum + dt
            local alpha = Util.Clamp(elapsed / suspenseTime, 0, 1)

            local _, currHrp = Util.GetCharacter()
            centerPos = currHrp and currHrp.Position or centerPos
            local shrink = Util.Lerp(24, 3.5, alpha)
            chargeRing.Size = Vector3.new(0.45, shrink, shrink)
            chargeRing.CFrame = CFrame.new(centerPos) * CFrame.Angles(elapsed * 5, elapsed * 3, math.rad(90))

            -- Falsas revelações de cores menores piscando antes da final
            if tickAccum >= Util.Lerp(0.28, 0.08, alpha) then
                tickAccum = 0
                local fakeTier = math.clamp(math.random(1, chosen.Tier), 1, 7)
                chargeRing.Color = RARITIES[fakeTier].Color
                Audio:Play("AuraTick", 0.9 + alpha * 0.7, 0.6)
                CameraFX:Shake(0.08 * alpha, 10)
            end
        end

        self:ClearCinematicVisuals()

        -- Explosão de Revelação
        CameraFX:Flash(rarity.Color, 0.92)
        CameraFX:Shake(rarity.Shake, 4.0)
        if chosen.Tier >= 4 then
            Audio:Play("AuraRevealHigh", 1.0, 1.0)
        else
            Audio:Play("AuraRevealLow", 1.0, 0.85)
        end

        if Cosmos.Modules.HUD then
            Cosmos.Modules.HUD:ShowAuraRevealResult(chosen, rarity)
        end

        -- Equipar automaticamente se for a primeira aura ou mais rara que a atual
        if not Cosmos.State.EquippedAura or chosen.Id >= Cosmos.State.EquippedAura then
            self:EquipAura(chosen.Id)
        end

        local waitReveal = self.SkipRequested and 0.35 or 1.85
        task.wait(waitReveal)
        if Cosmos.Modules.HUD then
            Cosmos.Modules.HUD:EndAuraCinematic()
        end
        Cosmos.State.RollingAura = false
    end)
end

function AuraRNG:SkipCinematic()
    self.SkipRequested = true
end

function AuraRNG:Update(dt)
    if self.RollTimer > 0 then
        self.RollTimer = math.max(0, self.RollTimer - dt)
    end
    if Cosmos.State.LuckTimer > 0 then
        Cosmos.State.LuckTimer = math.max(0, Cosmos.State.LuckTimer - dt)
        if Cosmos.State.LuckTimer <= 0 then
            Cosmos.State.BonusLuck = 0
        end
    end

    if Cosmos.State.AutoRoll and not Cosmos.State.RollingAura and self.RollTimer <= 0 then
        self:TriggerRoll()
    end

    -- Atualizar animação 3D da Aura equipada no personagem
    local auraId = Cosmos.State.EquippedAura
    if not auraId or #self.EquippedParts == 0 then return end
    local _, hrp = Util.GetCharacter()
    if not hrp then return end

    local aura = AURAS[auraId]
    self.SpinAngle = self.SpinAngle + dt * aura.SpinSpeed
    local basePos = hrp.Position
    local pulseScale = 1 + math.sin(self.SpinAngle * aura.Pulse) * 0.12

    for _, item in ipairs(self.EquippedParts) do
        if item.Type == "Ring" then
            local i = item.Index
            local tiltX = math.sin(self.SpinAngle * 0.7 + i) * 0.55
            local tiltZ = math.cos(self.SpinAngle * 0.6 + i) * 0.55
            item.Part.CFrame = CFrame.new(basePos - Vector3.new(0, 2.2 - i * 0.6, 0))
                * CFrame.Angles(tiltX, self.SpinAngle * (i % 2 == 0 and 1 or -1), math.rad(90) + tiltZ)
        elseif item.Type == "Orb" then
            local ang = (item.Index / item.Total) * math.pi * 2 + self.SpinAngle * 1.4
            local rad = (4.5 + (item.Index % 2) * 1.6) * pulseScale
            local yOff = math.sin(self.SpinAngle * 2 + item.Index) * 2.2
            item.Part.Position = basePos + Vector3.new(math.cos(ang) * rad, yOff, math.sin(ang) * rad)
        elseif item.Type == "Pillar" then
            local ang = (item.Index / item.Total) * math.pi * 2 - self.SpinAngle * 0.8
            local rad = 5.5 * pulseScale
            local pPos = basePos + Vector3.new(math.cos(ang) * rad, 0, math.sin(ang) * rad)
            item.Part.CFrame = CFrame.new(pPos) * CFrame.Angles(0, ang, math.rad(12 * math.sin(self.SpinAngle)))
        elseif item.Type == "BlackHole" then
            local bhPos = basePos + Vector3.new(0, 5.2, 0)
            item.Core.Position = bhPos
            item.Disk.CFrame = CFrame.new(bhPos) * CFrame.Angles(math.rad(25), self.SpinAngle * 2.5, math.rad(90))
        end
    end
end

function AuraRNG:Destroy()
    self:ClearEquippedVisuals()
    self:ClearCinematicVisuals()
    self.Maid:Clean()
end

--====================================================================================================
-- [SEÇÃO 11] MÓDULO 8: COMBAT FPS (VIEWMODEL 3D, SWAY, BOB, RECUO, SHELLS, TRACERS, 3 ARMAS)
--====================================================================================================
local CombatFPS = {
    Maid = Maid.new(),
    Enabled = false,
    AmmoInMag = { [1] = 32, [2] = 12, [3] = 5 },
    AmmoReserve = { [1] = 192, [2] = 96, [3] = 35 },
    FireCooldown = 0,
    Reloading = false,
    ReloadTimer = 0,
    CurrentSpread = 0.01,
    SwaySpring = Spring.new(Vector3.zero, 18, 0.8),
    RecoilSpring = Spring.new(Vector3.zero, 22, 0.72),
    BobTime = 0,
    ViewModel = nil,
    VMRoot = nil,
    VMBarrel = nil,
    MuzzleFlash = nil,
    MuzzleLight = nil,
    TracerPool = nil,
    ShellPool = nil,
    ActiveTracers = {},
    ActiveShells = {},
}
Util.RegisterModule("CombatFPS", CombatFPS)

function CombatFPS:BuildViewModel()
    if self.ViewModel then pcall(function() self.ViewModel:Destroy() end) end
    local vm = Instance.new("Model")
    vm.Name = "__CosmosViewModel"
    vm.Parent = WorldFolder
    self.ViewModel = vm
    self.Maid:Add(vm)

    local body = Util.CreatePart({
        Name = "GunBody",
        Material = Enum.Material.Metal,
        Color = Color3.fromRGB(28, 36, 44),
        Size = Vector3.new(0.35, 0.45, 2.2),
        Parent = vm
    })
    local stripe = Util.CreatePart({
        Name = "NeonAccent",
        Material = Enum.Material.Neon,
        Color = Color3.fromRGB(0, 240, 255),
        Size = Vector3.new(0.38, 0.12, 1.6),
        Parent = vm
    })
    local barrel = Util.CreatePart({
        Name = "Barrel",
        Material = Enum.Material.Metal,
        Color = Color3.fromRGB(16, 20, 24),
        Size = Vector3.new(0.18, 0.18, 1.2),
        Parent = vm
    })
    local scope = Util.CreatePart({
        Name = "HoloSight",
        Material = Enum.Material.Glass,
        Color = Color3.fromRGB(0, 255, 220),
        Transparency = 0.35,
        Size = Vector3.new(0.26, 0.24, 0.45),
        Parent = vm
    })
    local muzzle = Util.CreatePart({
        Name = "MuzzleFlash",
        Shape = Enum.PartType.Ball,
        Material = Enum.Material.Neon,
        Color = Color3.fromRGB(0, 240, 255),
        Transparency = 1,
        Size = Vector3.new(0.85, 0.85, 0.85),
        Parent = vm
    })
    local light = Instance.new("PointLight")
    light.Color = Color3.fromRGB(0, 240, 255)
    light.Range = 14
    light.Brightness = 0
    light.Parent = muzzle

    self.VMRoot = body
    self.VMStripe = stripe
    self.VMBarrel = barrel
    self.VMScope = scope
    self.MuzzleFlash = muzzle
    self.MuzzleLight = light
    self:SetViewModelVisible(false)
end

function CombatFPS:SetViewModelVisible(vis)
    local t = vis and 0 or 1
    if self.VMRoot then self.VMRoot.Transparency = t end
    if self.VMStripe then self.VMStripe.Transparency = t end
    if self.VMBarrel then self.VMBarrel.Transparency = t end
    if self.VMScope then self.VMScope.Transparency = vis and 0.35 or 1 end
    if not vis and self.MuzzleFlash then self.MuzzleFlash.Transparency = 1 end
end

function CombatFPS:Init()
    self:BuildViewModel()

    self.TracerPool = Pool.new(function()
        return Util.CreatePart({
            Name = "LaserTracer",
            Material = Enum.Material.Neon,
            Color = Color3.fromRGB(0, 240, 255),
            Transparency = 1,
            Size = Vector3.new(0.16, 0.16, 4),
            Parent = WorldFolder
        })
    end, function(p)
        p.Transparency = 1
        p.Position = Vector3.new(0, -9000, 0)
    end, 16)
    self.Maid:Add(self.TracerPool)

    self.ShellPool = Pool.new(function()
        return Util.CreatePart({
            Name = "EjectedShell",
            Material = Enum.Material.Metal,
            Color = Color3.fromRGB(235, 190, 75),
            Transparency = 1,
            Size = Vector3.new(0.12, 0.12, 0.32),
            Parent = WorldFolder
        })
    end, function(p)
        p.Transparency = 1
        p.Position = Vector3.new(0, -9000, 0)
    end, 12)
    self.Maid:Add(self.ShellPool)
end

function CombatFPS:SelectWeapon(index)
    local w = WEAPONS[index]
    if not w then return end
    Cosmos.State.CurrentWeapon = index
    self.Reloading = false
    self.CurrentSpread = w.SpreadBase
    if self.VMRoot then
        self.VMRoot.Size = w.BodySize
        self.VMStripe.Color = w.Color
        self.MuzzleFlash.Color = w.Color
        self.MuzzleLight.Color = w.Color
    end
    Audio:Play("UIClick", 1.1, 0.6)
end

function CombatFPS:SetEquipped(state)
    self.Enabled = state
    self:SetViewModelVisible(state)
    if not state then
        Cosmos.State.Aiming = false
        Cosmos.State.Shooting = false
    end
end

function CombatFPS:StartReload()
    local wIdx = Cosmos.State.CurrentWeapon
    local w = WEAPONS[wIdx]
    if self.Reloading or self.AmmoInMag[wIdx] >= w.MagSize or self.AmmoReserve[wIdx] <= 0 then
        return
    end
    self.Reloading = true
    self.ReloadTimer = w.ReloadTime
    Audio:Play("Reload", 1.0, 0.8)
end

function CombatFPS:FireSingleShot()
    local wIdx = Cosmos.State.CurrentWeapon
    local w = WEAPONS[wIdx]
    if self.Reloading or self.FireCooldown > 0 then return end

    if self.AmmoInMag[wIdx] <= 0 then
        self:StartReload()
        return
    end

    self.AmmoInMag[wIdx] = self.AmmoInMag[wIdx] - 1
    self.FireCooldown = w.FireRate

    -- Som e Flash de Cano
    if wIdx == 1 then Audio:Play("LaserRifle", 1.0, 0.8)
    elseif wIdx == 2 then Audio:Play("PlasmaShot", 1.0, 0.85)
    else Audio:Play("NovaShot", 1.0, 0.95) end

    if self.MuzzleFlash and self.MuzzleLight then
        self.MuzzleFlash.Transparency = 0.05
        self.MuzzleLight.Brightness = 3.5
    end

    -- Impulso de Recuo na Mola e Shake
    self.RecoilSpring:Impulse(Vector3.new(w.RecoilPitch, (math.random() - 0.5) * w.RecoilYaw, 1.8))
    CameraFX:Shake(0.14 * w.RecoilPitch, 12)

    -- Ejeção de Cartucho físico
    if self.VMRoot then
        local sh = self.ShellPool:Acquire()
        sh.Transparency = 0
        sh.CFrame = self.VMRoot.CFrame * CFrame.new(0.35, 0.15, 0)
        table.insert(self.ActiveShells, {
            Part = sh,
            Pos = sh.Position,
            Vel = (self.VMRoot.CFrame.RightVector * 9) + Vector3.new(0, 8, 0),
            Life = 0.85
        })
    end

    -- Raycast com Dispersão Dinâmica (Spread)
    local camCF = Camera.CFrame
    local spreadMult = Cosmos.State.Aiming and 0.35 or 1.0
    local sp = self.CurrentSpread * spreadMult
    local spreadDir = (camCF.LookVector + Vector3.new(
        (math.random() - 0.5) * sp,
        (math.random() - 0.5) * sp,
        (math.random() - 0.5) * sp
    )).Unit

    self.CurrentSpread = math.min(w.SpreadMax, self.CurrentSpread + w.SpreadInc)

    local origin = camCF.Position
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    local char = LocalPlayer.Character
    params.FilterDescendantsInstances = { char, self.ViewModel, Universe.StarShellFolder }

    local result = Services.Workspace:Raycast(origin, spreadDir * w.Range, params)
    local hitPos = result and result.Position or (origin + spreadDir * w.Range)

    -- Criar Tracer luminoso do cano até o ponto de impacto
    local startPos = self.VMBarrel and self.VMBarrel.Position or (origin + camCF.RightVector * 0.6 - camCF.UpVector * 0.4)
    local dist = (hitPos - startPos).Magnitude
    local tr = self.TracerPool:Acquire()
    tr.Color = w.Color
    tr.Transparency = 0.08
    tr.Size = Vector3.new(0.18, 0.18, math.min(dist, 180))
    tr.CFrame = CFrame.lookAt(startPos:Lerp(hitPos, 0.5), hitPos)
    table.insert(self.ActiveTracers, { Part = tr, Life = 0.11 })

    -- Processar acerto em Inimigos ou Props Destrutíveis
    if result and result.Instance then
        local hitInst = result.Instance
        local isHeadshot = (hitInst.Name == "EyeCore" or hitInst.Name == "Head")
        local dmg = w.Damage * (isHeadshot and w.HeadshotMult or 1.0)

        local hitConfirmed = false
        if Cosmos.Modules.EnemyAI and Cosmos.Modules.EnemyAI:HandleHit(hitInst, dmg, hitPos, w.ExplosiveRadius) then
            hitConfirmed = true
        end
        if Cosmos.Modules.Props and Cosmos.Modules.Props:HandleHit(hitInst, dmg, hitPos, w.ExplosiveRadius) then
            hitConfirmed = true
        end

        if hitConfirmed then
            Audio:Play("Hitmarker", isHeadshot and 1.45 or 1.15, 0.85)
            if Cosmos.Modules.HUD then
                Cosmos.Modules.HUD:TriggerHitmarker(isHeadshot)
            end
        end
    end
end

function CombatFPS:Update(dt)
    -- Atualizar Tracers e Cartuchos ativos no Pool
    for i = #self.ActiveTracers, 1, -1 do
        local item = self.ActiveTracers[i]
        item.Life = item.Life - dt
        if item.Life <= 0 then
            self.TracerPool:Release(item.Part)
            table.remove(self.ActiveTracers, i)
        else
            item.Part.Transparency = 1 - (item.Life / 0.11)
        end
    end

    for i = #self.ActiveShells, 1, -1 do
        local sh = self.ActiveShells[i]
        sh.Life = sh.Life - dt
        if sh.Life <= 0 then
            self.ShellPool:Release(sh.Part)
            table.remove(self.ActiveShells, i)
        else
            sh.Vel = sh.Vel - Vector3.new(0, 32 * dt, 0)
            sh.Pos = sh.Pos + sh.Vel * dt
            sh.Part.CFrame = CFrame.new(sh.Pos) * CFrame.Angles(sh.Life * 14, sh.Life * 9, 0)
        end
    end

    if self.MuzzleFlash and self.MuzzleFlash.Transparency < 1 then
        self.MuzzleFlash.Transparency = math.min(1, self.MuzzleFlash.Transparency + dt * 14)
        self.MuzzleLight.Brightness = math.max(0, self.MuzzleLight.Brightness - dt * 40)
    end

    if self.FireCooldown > 0 then
        self.FireCooldown = math.max(0, self.FireCooldown - dt)
    end

    local wIdx = Cosmos.State.CurrentWeapon
    local w = WEAPONS[wIdx]
    self.CurrentSpread = Util.Lerp(self.CurrentSpread, w.SpreadBase, dt * 6)

    -- Progresso de Recarga
    if self.Reloading then
        self.ReloadTimer = self.ReloadTimer - dt
        if self.ReloadTimer <= 0 then
            self.Reloading = false
            local needed = w.MagSize - self.AmmoInMag[wIdx]
            local transfer = math.min(needed, self.AmmoReserve[wIdx])
            self.AmmoInMag[wIdx] = self.AmmoInMag[wIdx] + transfer
            self.AmmoReserve[wIdx] = self.AmmoReserve[wIdx] - transfer
        end
    end

    if not self.Enabled or not Camera then
        self:SetViewModelVisible(false)
        return
    end

    self:SetViewModelVisible(true)

    -- Disparo contínuo (Rifle Automático ou toque no botão de tiro)
    if (Cosmos.State.Shooting or Cosmos.State.TouchInputs.Fire) and self.FireCooldown <= 0 then
        self:FireSingleShot()
        if not w.Automatic then
            Cosmos.State.Shooting = false
        end
    end

    -- Posicionar ViewModel 3D na frente da câmera com Sway, Bob e Recuo
    local _, hrp, hum = Util.GetCharacter()
    local moveSpd = (hrp and hrp.AssemblyLinearVelocity.Magnitude) or 0
    if hum and hum.MoveDirection.Magnitude > 0.05 then
        self.BobTime = self.BobTime + dt * math.clamp(moveSpd * 0.35, 4, 11)
    else
        self.BobTime = Util.Lerp(self.BobTime, 0, dt * 5)
    end

    local mouseDelta = Services.UserInputService:GetMouseDelta()
    self.SwaySpring.Target = Vector3.new(
        Util.Clamp(-mouseDelta.X * 0.008, -0.18, 0.18),
        Util.Clamp(mouseDelta.Y * 0.008, -0.18, 0.18),
        0
    )
    local sway = self.SwaySpring:Update(dt)
    local recoil = self.RecoilSpring:Update(dt)
    self.RecoilSpring.Target = Vector3.zero

    local baseOffset = Cosmos.State.Aiming and Vector3.new(0, -0.42, -1.55) or Vector3.new(0.78, -0.62, -1.85)
    local reloadDip = self.Reloading and Vector3.new(0, -0.65 * math.sin((1 - self.ReloadTimer / w.ReloadTime) * math.pi), 0) or Vector3.zero
    local bobOffset = Vector3.new(math.cos(self.BobTime) * 0.05, math.abs(math.sin(self.BobTime)) * 0.05, 0)

    local vmCF = Camera.CFrame
        * CFrame.new(baseOffset + sway + bobOffset + reloadDip + Vector3.new(0, 0, recoil.Z * 0.15))
        * CFrame.Angles(math.rad(recoil.X * 3.5), math.rad(recoil.Y * 2.5), 0)

    self.VMRoot.CFrame = vmCF
    self.VMStripe.CFrame = vmCF * CFrame.new(0, 0.12, 0)
    self.VMBarrel.CFrame = vmCF * CFrame.new(0, 0.06, -1.35)
    self.VMScope.CFrame = vmCF * CFrame.new(0, 0.32, -0.15)
    self.MuzzleFlash.CFrame = vmCF * CFrame.new(0, 0.06, -2.05)
end

function CombatFPS:Destroy()
    self.Maid:Clean()
end

--====================================================================================================
-- [SEÇÃO 12] MÓDULO 9: ENEMY AI (DRONES COM MÁQUINA DE ESTADOS, 4 TIPOS, CHEFE & LOOT)
--====================================================================================================
local EnemyAI = {
    Maid = Maid.new(),
    ActiveEnemies = {},
    PartToEnemy = {},
    ProjPool = nil,
    ActiveProjectiles = {},
    LootDrops = {},
    SpawnTimer = 4.0,
    WaveNumber = 1,
    BossSpawned = false,
}
Util.RegisterModule("EnemyAI", EnemyAI)

function EnemyAI:Init()
    self.ProjPool = Pool.new(function()
        return Util.CreatePart({
            Name = "EnemyPlasmaBolt",
            Shape = Enum.PartType.Ball,
            Material = Enum.Material.Neon,
            Color = Color3.fromRGB(255, 65, 65),
            Transparency = 1,
            Size = Vector3.new(1.3, 1.3, 1.3),
            Parent = WorldFolder
        })
    end, function(p)
        p.Transparency = 1
        p.Position = Vector3.new(0, -9000, 0)
    end, 30)
    self.Maid:Add(self.ProjPool)
end

function EnemyAI:SpawnDrone(typeKey, spawnPos)
    if #self.ActiveEnemies >= CONFIG.Enemies.MaxActive then return nil end
    local def = ENEMY_TYPES[typeKey] or ENEMY_TYPES.Scout
    local model = Instance.new("Model")
    model.Name = def.Name
    model.Parent = WorldFolder

    local r = def.Radius
    local hull = Util.CreatePart({
        Name = "Hull",
        Shape = Enum.PartType.Ball,
        Material = Enum.Material.Metal,
        Color = Color3.fromRGB(36, 44, 54),
        CanQuery = true,
        Size = Vector3.new(r * 2, r * 2, r * 2),
        Position = spawnPos,
        Parent = model
    })
    local eye = Util.CreatePart({
        Name = "EyeCore",
        Shape = Enum.PartType.Ball,
        Material = Enum.Material.Neon,
        Color = def.Color,
        CanQuery = true,
        Size = Vector3.new(r * 0.85, r * 0.85, r * 0.85),
        Position = spawnPos + Vector3.new(0, 0, -r * 0.85),
        Parent = model
    })
    local wingL = Util.CreatePart({
        Name = "WingL",
        Material = Enum.Material.Metal,
        Color = def.Color,
        CanQuery = true,
        Size = Vector3.new(r * 0.4, r * 1.6, r * 1.2),
        Parent = model
    })
    local wingR = Util.CreatePart({
        Name = "WingR",
        Material = Enum.Material.Metal,
        Color = def.Color,
        CanQuery = true,
        Size = Vector3.new(r * 0.4, r * 1.6, r * 1.2),
        Parent = model
    })

    -- BillboardGui com Barra de Vida Flutuante
    local bb = Instance.new("BillboardGui")
    bb.Size = UDim2.fromOffset(def.IsBoss and 150 or 90, 26)
    bb.StudsOffset = Vector3.new(0, r + 3.0, 0)
    bb.AlwaysOnTop = false
    bb.MaxDistance = 650
    bb.Parent = hull

    local bgFrame = Instance.new("Frame")
    bgFrame.Size = UDim2.fromScale(1, 0.42)
    bgFrame.Position = UDim2.fromScale(0, 0.55)
    bgFrame.BackgroundColor3 = Color3.fromRGB(14, 20, 26)
    bgFrame.BorderSizePixel = 0
    bgFrame.Parent = bb

    local hpFill = Instance.new("Frame")
    hpFill.Size = UDim2.fromScale(1, 1)
    hpFill.BackgroundColor3 = def.Color
    hpFill.BorderSizePixel = 0
    hpFill.Parent = bgFrame

    local nameLbl = Instance.new("TextLabel")
    nameLbl.Size = UDim2.fromScale(1, 0.5)
    nameLbl.BackgroundTransparency = 1
    nameLbl.Font = Enum.Font.GothamBold
    nameLbl.TextSize = 11
    nameLbl.TextColor3 = Color3.fromRGB(240, 250, 255)
    nameLbl.Text = def.Name
    nameLbl.Parent = bb

    local enemy = {
        TypeKey = typeKey,
        Def = def,
        Model = model,
        Hull = hull,
        Eye = eye,
        WingL = wingL,
        WingR = wingR,
        HPBar = hpFill,
        Health = def.MaxHealth,
        MaxHealth = def.MaxHealth,
        Shield = def.Shield,
        Position = spawnPos,
        HomePos = spawnPos,
        State = "Patrol", -- Patrol, Alert, Chase, Attack, Evade, Retreat, Dead
        StateTimer = 0,
        FireTimer = math.random() * 1.2,
        PatrolAngle = math.random() * math.pi * 2,
        EvadeVec = Vector3.zero,
    }

    self.PartToEnemy[hull] = enemy
    self.PartToEnemy[eye] = enemy
    self.PartToEnemy[wingL] = enemy
    self.PartToEnemy[wingR] = enemy
    table.insert(self.ActiveEnemies, enemy)
    return enemy
end

function EnemyAI:HandleHit(hitPart, damage, hitPos, explosiveRadius)
    local target = self.PartToEnemy[hitPart]
    local hitAny = false

    if target and target.State ~= "Dead" then
        self:DamageEnemy(target, damage)
        hitAny = true
    end

    if explosiveRadius and explosiveRadius > 0 then
        for _, en in ipairs(self.ActiveEnemies) do
            if en ~= target and en.State ~= "Dead" then
                local d = (en.Position - hitPos).Magnitude
                if d <= explosiveRadius then
                    self:DamageEnemy(en, damage * 0.75)
                    hitAny = true
                end
            end
        end
    end

    return hitAny
end

function EnemyAI:DamageEnemy(en, amount)
    if en.State == "Dead" then return end
    if en.Shield > 0 then
        local absorb = math.min(en.Shield, amount)
        en.Shield = en.Shield - absorb
        amount = amount - absorb
    end
    en.Health = en.Health - amount
    if en.HPBar then
        en.HPBar.Size = UDim2.fromScale(Util.Clamp(en.Health / en.MaxHealth, 0, 1), 1)
    end

    if en.Health <= 0 then
        en.State = "Dead"
        self:KillEnemy(en)
    elseif en.Health < en.MaxHealth * 0.22 and not en.Def.IsBoss then
        en.State = "Retreat"
        en.StateTimer = 2.5
    else
        en.State = "Evade"
        en.StateTimer = 0.65
        en.EvadeVec = Vector3.new(math.random(-1, 1), math.random(-1, 1), math.random(-1, 1)).Unit * en.Def.Speed * 1.4
    end
end

function EnemyAI:KillEnemy(en)
    Audio:Play("Explosion", 1.0, 0.85)
    CameraFX:Shake(en.Def.IsBoss and 1.2 or 0.35, 6.0)

    -- Spawn de Cristal de Loot (XP + Munição + Luck Temporário)
    local crystal = Util.CreatePart({
        Name = "LootCrystal",
        Material = Enum.Material.Neon,
        Color = Color3.fromRGB(95, 255, 215),
        Size = Vector3.new(2.2, 3.6, 2.2),
        Position = en.Position,
        Parent = WorldFolder
    })
    table.insert(self.LootDrops, { Part = crystal, Pos = en.Position, XP = en.Def.XP, Life = 22 })

    -- Remover referências
    self.PartToEnemy[en.Hull] = nil
    self.PartToEnemy[en.Eye] = nil
    self.PartToEnemy[en.WingL] = nil
    self.PartToEnemy[en.WingR] = nil
    pcall(function() en.Model:Destroy() end)

    for i = #self.ActiveEnemies, 1, -1 do
        if self.ActiveEnemies[i] == en then
            table.remove(self.ActiveEnemies, i)
            break
        end
    end

    Cosmos.State.EnemiesKilled = Cosmos.State.EnemiesKilled + 1
    if Cosmos.Modules.Missions then
        Cosmos.Modules.Missions:AddXP(en.Def.XP)
        Cosmos.Modules.Missions:NotifyProgress("m_drones5", 1)
        if Cosmos.State.EnemiesKilled >= 15 then
            Cosmos.Modules.Missions:UnlockAchievement("a_slayer")
        end
        if en.Def.IsBoss then
            Cosmos.State.BossesKilled = Cosmos.State.BossesKilled + 1
            self.BossSpawned = false
            Cosmos.Modules.Missions:NotifyProgress("m_boss", 1)
        end
    end
end

function EnemyAI:FireProjectile(en, targetPos, targetVel)
    local pr = self.ProjPool:Acquire()
    pr.Color = en.Def.Color
    pr.Transparency = 0.05
    local size = en.Def.IsBoss and 2.8 or 1.4
    pr.Size = Vector3.new(size, size, size)
    pr.Position = en.Position

    -- Previsão simples de alvo
    local dist = (targetPos - en.Position).Magnitude
    local travelTime = dist / en.Def.ProjectileSpeed
    local predicted = targetPos + (targetVel or Vector3.zero) * (travelTime * 0.55)
    local dir = (predicted - en.Position).Unit

    table.insert(self.ActiveProjectiles, {
        Part = pr,
        Pos = en.Position,
        Vel = dir * en.Def.ProjectileSpeed,
        Damage = en.Def.Damage,
        Homing = en.Def.Homing,
        Life = 4.5,
    })
end

function EnemyAI:Update(dt)
    local _, hrp = Util.GetCharacter()
    local playerPos = hrp and hrp.Position or (Camera and Camera.CFrame.Position or Vector3.zero)
    local playerVel = hrp and hrp.AssemblyLinearVelocity or Vector3.zero

    -- 1. Spawner Automático de Ondas e Boss
    self.SpawnTimer = self.SpawnTimer - dt
    if self.SpawnTimer <= 0 and Cosmos.Started then
        self.SpawnTimer = CONFIG.Enemies.SpawnInterval
        if #self.ActiveEnemies < CONFIG.Enemies.MaxActive then
            local ang = math.random() * math.pi * 2
            local spawnPos = playerPos + Vector3.new(math.cos(ang) * 180, math.random(25, 85), math.sin(ang) * 180)
            if Cosmos.State.EnemiesKilled >= 8 and not self.BossSpawned then
                self.BossSpawned = true
                self:SpawnDrone("Boss", spawnPos + Vector3.new(0, 45, 0))
                if Cosmos.Modules.HUD then
                    Cosmos.Modules.HUD:Notify("ALERTA DE CHEFE", "Guardião Estelar Omega detectado no setor!", Color3.fromRGB(255, 65, 95))
                end
            else
                local roll = math.random(1, 10)
                local tKey = (roll <= 5) and "Scout" or ((roll <= 8) and "Gunner" or "Heavy")
                self:SpawnDrone(tKey, spawnPos)
            end
        end
    end

    -- 2. Máquina de Estados dos Drones Ativos
    for i = #self.ActiveEnemies, 1, -1 do
        local en = self.ActiveEnemies[i]
        local def = en.Def
        local toPlayer = playerPos - en.Position
        local dist = toPlayer.Magnitude

        if en.State == "Evade" then
            en.StateTimer = en.StateTimer - dt
            en.Position = en.Position + en.EvadeVec * dt
            if en.StateTimer <= 0 then en.State = "Attack" end
        elseif en.State == "Retreat" then
            en.StateTimer = en.StateTimer - dt
            local away = (en.Position - playerPos).Unit
            en.Position = en.Position + away * (def.Speed * 1.25 * dt)
            if en.StateTimer <= 0 then en.State = "Chase" end
        elseif dist <= def.DetectRange then
            if dist <= def.AttackRange then
                en.State = "Attack"
            else
                en.State = "Chase"
            end
        else
            en.State = "Patrol"
        end

        if en.State == "Patrol" then
            en.PatrolAngle = en.PatrolAngle + dt * 0.8
            local target = en.HomePos + Vector3.new(math.cos(en.PatrolAngle) * 45, math.sin(en.PatrolAngle * 2) * 12, math.sin(en.PatrolAngle) * 45)
            en.Position = en.Position:Lerp(target, Util.Clamp(dt * 2, 0, 1))
        elseif en.State == "Chase" then
            local dir = toPlayer.Unit
            en.Position = en.Position + dir * (def.Speed * dt)
        elseif en.State == "Attack" then
            -- Orbitar o jogador enquanto dispara
            en.PatrolAngle = en.PatrolAngle + dt * 0.9
            local orbitOffset = Vector3.new(math.cos(en.PatrolAngle) * 85, 22, math.sin(en.PatrolAngle) * 85)
            local desiredPos = playerPos + orbitOffset
            en.Position = en.Position:Lerp(desiredPos, Util.Clamp(dt * 1.8, 0, 1))

            en.FireTimer = en.FireTimer - dt
            if en.FireTimer <= 0 then
                en.FireTimer = def.FireRate
                self:FireProjectile(en, playerPos, playerVel)
            end
        end

        -- Atualizar CFrame das Parts do Drone
        local lookCF = CFrame.lookAt(en.Position, playerPos)
        local r = def.Radius
        en.Hull.CFrame = lookCF
        en.Eye.CFrame = lookCF * CFrame.new(0, 0, -r * 0.88)
        en.WingL.CFrame = lookCF * CFrame.new(-r * 1.15, 0, 0) * CFrame.Angles(0, 0, math.rad(18))
        en.WingR.CFrame = lookCF * CFrame.new(r * 1.15, 0, 0) * CFrame.Angles(0, 0, math.rad(-18))
    end

    -- 3. Atualizar Projéteis Inimigos e Dano ao Jogador
    for i = #self.ActiveProjectiles, 1, -1 do
        local pr = self.ActiveProjectiles[i]
        pr.Life = pr.Life - dt
        if pr.Homing and hrp then
            local toP = (playerPos - pr.Pos).Unit
            pr.Vel = pr.Vel:Lerp(toP * pr.Vel.Magnitude, dt * 2.5)
        end
        pr.Pos = pr.Pos + pr.Vel * dt
        pr.Part.Position = pr.Pos

        local hitPlayer = hrp and ((pr.Pos - playerPos).Magnitude < 4.5)
        if hitPlayer then
            self:DamagePlayer(pr.Damage)
            self.ProjPool:Release(pr.Part)
            table.remove(self.ActiveProjectiles, i)
        elseif pr.Life <= 0 then
            self.ProjPool:Release(pr.Part)
            table.remove(self.ActiveProjectiles, i)
        end
    end

    -- 4. Atualizar Coleta de Cristais de Loot
    for i = #self.LootDrops, 1, -1 do
        local lt = self.LootDrops[i]
        lt.Life = lt.Life - dt
        lt.Part.CFrame = CFrame.new(lt.Pos + Vector3.new(0, math.sin(Cosmos.TimeElapsed * 4) * 1.2, 0))
            * CFrame.Angles(0, Cosmos.TimeElapsed * 2.5, math.rad(25))

        if (lt.Pos - playerPos).Magnitude < 18 then
            lt.Pos = lt.Pos:Lerp(playerPos, dt * 12)
        end
        if (lt.Pos - playerPos).Magnitude < 5.5 then
            Cosmos.State.BonusLuck = math.min(5.0, Cosmos.State.BonusLuck + 0.5)
            Cosmos.State.LuckTimer = 45.0
            Cosmos.State.Shield = math.min(Cosmos.State.MaxShield, Cosmos.State.Shield + 20)
            for w = 1, #WEAPONS do
                CombatFPS.AmmoReserve[w] = math.min(WEAPONS[w].ReserveMax, CombatFPS.AmmoReserve[w] + math.floor(WEAPONS[w].MagSize * 0.5))
            end
            Audio:Play("Notify", 1.35, 0.7)
            pcall(function() lt.Part:Destroy() end)
            table.remove(self.LootDrops, i)
        elseif lt.Life <= 0 then
            pcall(function() lt.Part:Destroy() end)
            table.remove(self.LootDrops, i)
        end
    end
end

function EnemyAI:DamagePlayer(dmg)
    if Cosmos.State.Shield > 0 then
        local sDmg = math.min(Cosmos.State.Shield, dmg)
        Cosmos.State.Shield = Cosmos.State.Shield - sDmg
        dmg = dmg - sDmg
    end
    if dmg > 0 then
        Cosmos.State.Health = math.max(0, Cosmos.State.Health - dmg)
    end
    CameraFX:Flash(Color3.fromRGB(255, 45, 55), 0.38)
    CameraFX:Shake(0.35, 8.0)

    if Cosmos.State.Health <= 0 then
        Cosmos.State.Health = Cosmos.State.MaxHealth
        Cosmos.State.Shield = Cosmos.State.MaxShield
        Cosmos.State.Oxygen = Cosmos.State.MaxOxygen
        if Cosmos.Modules.HUD then
            Cosmos.Modules.HUD:Notify("TRAJE REINICIADO", "Escudos de emergência restaurados!", CONFIG.UI.WarnColor)
        end
    end
end

function EnemyAI:Destroy()
    for _, en in ipairs(self.ActiveEnemies) do
        pcall(function() en.Model:Destroy() end)
    end
    for _, lt in ipairs(self.LootDrops) do
        pcall(function() lt.Part:Destroy() end)
    end
    table.clear(self.ActiveEnemies)
    table.clear(self.PartToEnemy)
    self.Maid:Clean()
end

--====================================================================================================
-- [SEÇÃO 13] MÓDULO 10: DESTRUCTIBLE PROPS (CAIXAS, BARRIS EXPLOSIVOS, SATÉLITES & POOL DE DETRITOS)
--====================================================================================================
local Props = {
    Maid = Maid.new(),
    PropList = {},
    PartToProp = {},
    DebrisPool = nil,
    ActiveDebris = {},
}
Util.RegisterModule("Props", Props)

function Props:Init()
    self.DebrisPool = Pool.new(function()
        return Util.CreatePart({
            Name = "PropDebris",
            Material = Enum.Material.Metal,
            Color = Color3.fromRGB(120, 130, 140),
            Transparency = 1,
            Size = Vector3.new(1.6, 1.2, 1.8),
            Parent = WorldFolder
        })
    end, function(p)
        p.Transparency = 1
        p.Position = Vector3.new(0, -9000, 0)
    end, CONFIG.Props.MaxDebris)
    self.Maid:Add(self.DebrisPool)

    -- Criar 24 Props destrutíveis próximos à Terra Prime, Luna Alpha e Cinturão
    local rng = Random.new(CONFIG.SeedUniverse + 404)
    for i = 1, 24 do
        local isExplosive = (i % 4 == 0)
        local isSatellite = (i % 3 == 0 and not isExplosive)
        local baseAnchor = (i <= 12) and Vector3.new(0, 60, 0) or CONFIG.BeltCenter
        local offset = Vector3.new(rng:NextNumber(-260, 260), rng:NextNumber(8, 120), rng:NextNumber(-260, 260))
        local pos = baseAnchor + offset

        local col = isExplosive and Color3.fromRGB(235, 65, 45)
            or (isSatellite and Color3.fromRGB(65, 155, 235) or Color3.fromRGB(145, 160, 175))
        local sz = isExplosive and Vector3.new(5.5, 7.5, 5.5)
            or (isSatellite and Vector3.new(12, 3, 6) or Vector3.new(6.5, 6.5, 6.5))

        local part = Util.CreatePart({
            Name = isExplosive and "ExplosiveBarrel" or (isSatellite and "SolarPanelProp" or "SupplyCrate"),
            Shape = isExplosive and Enum.PartType.Cylinder or Enum.PartType.Block,
            Material = Enum.Material.Metal,
            Color = col,
            CanCollide = true,
            CanQuery = true,
            Size = sz,
            Position = pos,
            Parent = WorldFolder
        })
        self.Maid:Add(part)

        local propObj = {
            Part = part,
            SpawnPos = pos,
            BaseColor = col,
            BaseSize = sz,
            MaxHealth = isExplosive and 50 or 90,
            Health = isExplosive and 50 or 90,
            IsExplosive = isExplosive,
            Destroyed = false,
            RespawnTimer = 0,
        }
        table.insert(self.PropList, propObj)
        self.PartToProp[part] = propObj
    end
end

function Props:HandleHit(hitPart, damage, hitPos, explosiveRadius)
    local prop = self.PartToProp[hitPart]
    local hitAny = false
    if prop and not prop.Destroyed then
        self:DamageProp(prop, damage)
        hitAny = true
    end
    if explosiveRadius and explosiveRadius > 0 then
        for _, pr in ipairs(self.PropList) do
            if pr ~= prop and not pr.Destroyed and (pr.Part.Position - hitPos).Magnitude <= explosiveRadius then
                self:DamageProp(pr, damage * 0.8)
                hitAny = true
            end
        end
    end
    return hitAny
end

function Props:DamageProp(prop, dmg)
    if prop.Destroyed then return end
    prop.Health = prop.Health - dmg

    -- Estágios visuais de rachadura (mudança de material e cor)
    local ratio = prop.Health / prop.MaxHealth
    if ratio <= 0 then
        self:ShatterProp(prop)
    elseif ratio < 0.45 then
        prop.Part.Material = Enum.Material.CorrodedMetal
        prop.Part.Color = prop.BaseColor:Lerp(Color3.fromRGB(40, 25, 20), 0.5)
    elseif ratio < 0.75 then
        prop.Part.Material = Enum.Material.DiamondPlate
    end
end

function Props:ShatterProp(prop)
    prop.Destroyed = true
    prop.RespawnTimer = CONFIG.Props.RespawnTime
    local pos = prop.Part.Position
    prop.Part.Transparency = 1
    prop.Part.CanCollide = false
    prop.Part.CanQuery = false

    Audio:Play("Explosion", prop.IsExplosive and 0.75 or 1.15, prop.IsExplosive and 0.95 or 0.65)
    CameraFX:Shake(prop.IsExplosive and 0.75 or 0.25, 6.0)

    -- Despedaçar em detritos do Pool
    for d = 1, 6 do
        local deb = self.DebrisPool:Acquire()
        deb.Color = prop.BaseColor
        deb.Transparency = 0
        deb.Position = pos
        local vel = Vector3.new(math.random(-28, 28), math.random(12, 36), math.random(-28, 28))
        table.insert(self.ActiveDebris, { Part = deb, Pos = pos, Vel = vel, Life = 2.4 })
    end

    -- Se for barril explosivo, causa dano em área em outros props e drones inimigos
    if prop.IsExplosive then
        CameraFX:Flash(Color3.fromRGB(255, 130, 40), 0.45)
        if Cosmos.Modules.EnemyAI then
            Cosmos.Modules.EnemyAI:HandleHit(nil, 110, pos, 36)
        end
        for _, other in ipairs(self.PropList) do
            if other ~= prop and not other.Destroyed and (other.Part.Position - pos).Magnitude < 32 then
                self:DamageProp(other, 95)
            end
        end
    end

    Cosmos.State.PropsDestroyed = Cosmos.State.PropsDestroyed + 1
    if Cosmos.Modules.Missions then
        Cosmos.Modules.Missions:AddXP(25)
        Cosmos.Modules.Missions:NotifyProgress("m_props10", 1)
    end
end

function Props:Update(dt)
    for i = #self.ActiveDebris, 1, -1 do
        local deb = self.ActiveDebris[i]
        deb.Life = deb.Life - dt
        if deb.Life <= 0 then
            self.DebrisPool:Release(deb.Part)
            table.remove(self.ActiveDebris, i)
        else
            deb.Vel = deb.Vel - Vector3.new(0, 38 * dt, 0)
            deb.Pos = deb.Pos + deb.Vel * dt
            deb.Part.CFrame = CFrame.new(deb.Pos) * CFrame.Angles(deb.Life * 6, deb.Life * 4, 0)
            if deb.Life < 0.6 then
                deb.Part.Transparency = 1 - (deb.Life / 0.6)
            end
        end
    end

    for _, prop in ipairs(self.PropList) do
        if prop.Destroyed then
            prop.RespawnTimer = prop.RespawnTimer - dt
            if prop.RespawnTimer <= 0 then
                prop.Destroyed = false
                prop.Health = prop.MaxHealth
                prop.Part.Material = Enum.Material.Metal
                prop.Part.Color = prop.BaseColor
                prop.Part.Transparency = 0
                prop.Part.CanCollide = true
                prop.Part.CanQuery = true
                prop.Part.Position = prop.SpawnPos
            end
        end
    end
end

function Props:Destroy()
    self.Maid:Clean()
end
-- CONTINUA NA PARTE 4/4

--====================================================================================================
-- PARTE 4/4: HUD SCI-FI COMPLETO, CONTROLES TOUCH MOBILE, MISSÕES, QUALIDADE DINÂMICA & MAIN LOOP
--====================================================================================================

--====================================================================================================
-- [SEÇÃO 14] MÓDULO 14: MISSIONS & ACHIEVEMENTS (PROGRESSÃO EM SESSÃO, XP E NÍVEL)
--====================================================================================================
local Missions = {
    Maid = Maid.new(),
    Progress = {},
}
Util.RegisterModule("Missions", Missions)

function Missions:Init()
    for _, m in ipairs(MISSIONS) do
        self.Progress[m.Id] = 0
    end
end

function Missions:AddXP(amount)
    Cosmos.State.XP = Cosmos.State.XP + amount
    local req = Cosmos.State.Level * 200
    while Cosmos.State.XP >= req do
        Cosmos.State.XP = Cosmos.State.XP - req
        Cosmos.State.Level = Cosmos.State.Level + 1
        Cosmos.State.BaseLuck = Cosmos.State.BaseLuck + 0.15
        req = Cosmos.State.Level * 200
        if Cosmos.Modules.HUD then
            Cosmos.Modules.HUD:Notify("NÍVEL ALCANÇADO!", "Você subiu para o Nível " .. Cosmos.State.Level .. " (+0.15 Luck Permanente)", CONFIG.UI.AccentColor)
        end
    end
end

function Missions:NotifyProgress(missionId, delta)
    if Cosmos.State.CompletedMissions[missionId] then return end
    self.Progress[missionId] = (self.Progress[missionId] or 0) + (delta or 1)

    for _, m in ipairs(MISSIONS) do
        if m.Id == missionId and self.Progress[missionId] >= m.Goal then
            Cosmos.State.CompletedMissions[missionId] = true
            self:AddXP(m.RewardXP)
            Cosmos.State.BonusLuck = Cosmos.State.BonusLuck + m.RewardLuck
            Cosmos.State.LuckTimer = math.max(Cosmos.State.LuckTimer, 60)
            Audio:Play("Notify", 1.2, 0.9)
            if Cosmos.Modules.HUD then
                Cosmos.Modules.HUD:Notify("MISSÃO CONCLUÍDA: " .. m.Title, "+" .. m.RewardXP .. " XP | +" .. m.RewardLuck .. "x Luck!", Color3.fromRGB(85, 255, 165))
            end
            break
        end
    end
end

function Missions:NotifyPlanetVisited(planetName)
    local count = 0
    for _ in pairs(Cosmos.State.PlanetsVisited) do
        count = count + 1
    end
    self.Progress["m_planets"] = count
    if count >= 3 and not Cosmos.State.CompletedMissions["m_planets"] then
        self:NotifyProgress("m_planets", 0)
    end
    if count >= #BODIES then
        self:UnlockAchievement("a_explorer")
    end
    if Cosmos.Modules.HUD then
        Cosmos.Modules.HUD:Notify("NOVO CORPO CELESTE", "Você descobriu " .. planetName, CONFIG.UI.StrokeColor)
    end
end

function Missions:UnlockAchievement(achId)
    if Cosmos.State.UnlockedAchievements[achId] then return end
    Cosmos.State.UnlockedAchievements[achId] = true
    for _, a in ipairs(ACHIEVEMENTS) do
        if a.Id == achId then
            self:AddXP(150)
            Audio:Play("Notify", 1.4, 1.0)
            if Cosmos.Modules.HUD then
                Cosmos.Modules.HUD:Notify("CONQUISTA DESBLOQUEADA!", a.Title .. " — " .. a.Desc, Color3.fromRGB(255, 215, 65))
            end
            break
        end
    end
end

function Missions:Update(_dt) end
function Missions:Destroy() self.Maid:Clean() end

--====================================================================================================
-- [SEÇÃO 15] MÓDULO 13: SETTINGS / QUALITY / DEBUG (QUALIDADE DINÂMICA AUTOMÁTICA)
--====================================================================================================
local QualityMgr = {
    Maid = Maid.new(),
    FPSWindow = {},
    LowTimer = 0,
    HighTimer = 0,
}
Util.RegisterModule("QualityMgr", QualityMgr)

function QualityMgr:Init() end

function QualityMgr:SetQuality(level)
    Cosmos.QualityLevel = Util.Clamp(level, 1, 3)
    if Cosmos.Modules.HUD then
        local names = { [1] = "BAIXA", [2] = "MÉDIA", [3] = "ALTA" }
        Cosmos.Modules.HUD:UpdateQualityLabel(names[Cosmos.QualityLevel])
    end
end

function QualityMgr:Update(dt)
    local instFPS = 1 / math.max(0.001, dt)
    table.insert(self.FPSWindow, instFPS)
    if #self.FPSWindow > 60 then
        table.remove(self.FPSWindow, 1)
    end
    local sum = 0
    for i = 1, #self.FPSWindow do sum = sum + self.FPSWindow[i] end
    Cosmos.CurrentFPS = math.floor(sum / #self.FPSWindow)

    if not Cosmos.DynamicQuality then return end

    if Cosmos.CurrentFPS < 30 then
        self.LowTimer = self.LowTimer + dt
        self.HighTimer = 0
        if self.LowTimer >= 3.0 and Cosmos.QualityLevel > 1 then
            self.LowTimer = 0
            self:SetQuality(Cosmos.QualityLevel - 1)
        end
    elseif Cosmos.CurrentFPS > 55 then
        self.HighTimer = self.HighTimer + dt
        self.LowTimer = 0
        if self.HighTimer >= 10.0 and Cosmos.QualityLevel < 3 then
            self.HighTimer = 0
            self:SetQuality(Cosmos.QualityLevel + 1)
        end
    else
        self.LowTimer = 0
        self.HighTimer = 0
    end
end

function QualityMgr:Destroy() self.Maid:Clean() end

--====================================================================================================
-- [SEÇÃO 16] MÓDULO 6: HUD SCI-FI COMPLETO & CONTROLES MOBILE (BÚSSOLA, RADAR, HOTBAR, PAINÉIS)
--====================================================================================================
local HUD = {
    Maid = Maid.new(),
    ScreenGui = nil,
    CompassMarkers = {},
    RadarDots = {},
    HotbarButtons = {},
    Modals = {},
    HitmarkerTimer = 0,
}
Util.RegisterModule("HUD", HUD)

function HUD:CreateStyledFrame(props)
    local f = Instance.new("Frame")
    f.Name = props.Name or "SciFiPanel"
    f.Size = props.Size or UDim2.fromOffset(100, 100)
    f.Position = props.Position or UDim2.new()
    f.AnchorPoint = props.AnchorPoint or Vector2.zero
    f.BackgroundColor3 = props.Color or CONFIG.UI.BgColor
    f.BackgroundTransparency = (props.Transparency ~= nil) and props.Transparency or 0.22
    f.BorderSizePixel = 0
    if props.Parent then f.Parent = props.Parent end

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, props.Corner or 6)
    corner.Parent = f

    if not props.NoStroke then
        local stroke = Instance.new("UIStroke")
        stroke.Color = props.StrokeColor or CONFIG.UI.StrokeColor
        stroke.Thickness = props.StrokeThickness or 1.2
        stroke.Transparency = props.StrokeTransparency or 0.25
        stroke.Parent = f
    end
    return f
end

function HUD:CreateButton(props)
    local btn = Instance.new("TextButton")
    btn.Name = props.Name or "SciFiBtn"
    btn.Size = props.Size or UDim2.fromOffset(110, 48)
    btn.Position = props.Position or UDim2.new()
    btn.AnchorPoint = props.AnchorPoint or Vector2.zero
    btn.BackgroundColor3 = props.Color or CONFIG.UI.PanelColor
    btn.BackgroundTransparency = props.Transparency or 0.15
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = props.TextSize or 13
    btn.TextColor3 = props.TextColor or CONFIG.UI.TextColor
    btn.Text = props.Text or "BOTÃO"
    btn.AutoButtonColor = true
    if props.Parent then btn.Parent = props.Parent end

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, props.Corner or 8)
    corner.Parent = btn

    local stroke = Instance.new("UIStroke")
    stroke.Color = props.StrokeColor or CONFIG.UI.StrokeColor
    stroke.Thickness = 1.3
    stroke.Transparency = 0.2
    stroke.Parent = btn

    if props.OnClick then
        self.Maid:Add(btn.Activated:Connect(function()
            Audio:Play("UIClick", 1.15, 0.6)
            props.OnClick()
        end))
    end
    return btn
end

function HUD:ResolveGuiParent()
    local ok, hui = pcall(function()
        if type(gethui) == "function" then return gethui() end
        return nil
    end)
    if ok and hui then return hui end
    return LocalPlayer:WaitForChild("PlayerGui", 5) or Services.StarterGui
end

function HUD:Init()
    local sg = Instance.new("ScreenGui")
    sg.Name = "__CosmosOdysseyHUD"
    sg.ResetOnSpawn = false
    sg.IgnoreGuiInset = true
    sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    sg.Parent = self:ResolveGuiParent()
    self.ScreenGui = sg
    self.Maid:Add(sg)

    local uiScale = Instance.new("UIScale")
    uiScale.Parent = sg
    self.UIScale = uiScale

    -- Camada de Flash de Tela Cheia
    local flashFrame = Instance.new("Frame")
    flashFrame.Size = UDim2.fromScale(1, 1)
    flashFrame.BackgroundColor3 = Color3.new(1, 1, 1)
    flashFrame.BackgroundTransparency = 1
    flashFrame.ZIndex = 90
    flashFrame.Active = false
    flashFrame.Parent = sg
    self.FlashFrame = flashFrame

    -- Container principal do HUD de jogo
    local mainHud = Instance.new("Frame")
    mainHud.Name = "GameplayHUD"
    mainHud.Size = UDim2.fromScale(1, 1)
    mainHud.BackgroundTransparency = 1
    mainHud.Visible = false
    mainHud.Parent = sg
    self.GameplayHUD = mainHud

    self:BuildTopCompass(mainHud)
    self:BuildStatusAndAltimeter(mainHud)
    self:BuildRadar(mainHud)
    self:BuildHotbar(mainHud)
    self:BuildCrosshairAndWeaponHUD(mainHud)
    self:BuildMobileTouchControls(mainHud)
    self:BuildNotificationStack(sg)
    self:BuildModals(sg)
    self:BuildAuraCinematicOverlay(sg)
    self:BuildStartScreen(sg)
    self:SetupKeyboardShortcuts()
end

function HUD:BuildTopCompass(parent)
    local bar = self:CreateStyledFrame({
        Name = "CompassBar",
        Size = UDim2.new(0.54, 0, 0, 42),
        Position = UDim2.new(0.5, 0, 0, 12),
        AnchorPoint = Vector2.new(0.5, 0),
        Parent = parent
    })
    bar.ClipsDescendants = true
    self.CompassBar = bar

    local degLabel = Instance.new("TextLabel")
    degLabel.Size = UDim2.fromOffset(90, 18)
    degLabel.Position = UDim2.new(0.5, 0, 0, 2)
    degLabel.AnchorPoint = Vector2.new(0.5, 0)
    degLabel.BackgroundTransparency = 1
    degLabel.Font = Enum.Font.Code
    degLabel.TextSize = 13
    degLabel.TextColor3 = CONFIG.UI.AccentColor
    degLabel.Text = "000° N"
    degLabel.Parent = bar
    self.CompassHeadingLbl = degLabel

    -- Criar marcadores de planetas e luas na bússola
    for _, b in ipairs(Universe:GetAllBodiesList()) do
        local mk = Instance.new("TextLabel")
        mk.Size = UDim2.fromOffset(95, 22)
        mk.AnchorPoint = Vector2.new(0.5, 0)
        mk.BackgroundTransparency = 1
        mk.Font = Enum.Font.GothamBold
        mk.TextSize = 10
        mk.TextColor3 = b.Def.Color
        mk.Text = "◆ " .. b.Def.Name
        mk.Parent = bar
        self.CompassMarkers[b.Def.Id] = { Body = b, Label = mk }
    end
end

function HUD:BuildStatusAndAltimeter(parent)
    -- Painel Esquerdo: Vida, Escudo, Energia de Voo, Oxigênio e XP
    local statusPanel = self:CreateStyledFrame({
        Name = "StatusPanel",
        Size = UDim2.fromOffset(230, 142),
        Position = UDim2.new(0, 14, 0, 62),
        Parent = parent
    })

    local function makeBar(yPos, labelText, fillCol)
        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.fromOffset(72, 16)
        lbl.Position = UDim2.fromOffset(10, yPos)
        lbl.BackgroundTransparency = 1
        lbl.Font = Enum.Font.Code
        lbl.TextSize = 11
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.TextColor3 = CONFIG.UI.SubTextColor
        lbl.Text = labelText
        lbl.Parent = statusPanel

        local bg = Instance.new("Frame")
        bg.Size = UDim2.fromOffset(132, 10)
        bg.Position = UDim2.fromOffset(86, yPos + 3)
        bg.BackgroundColor3 = Color3.fromRGB(18, 36, 44)
        bg.BorderSizePixel = 0
        bg.Parent = statusPanel

        local fill = Instance.new("Frame")
        fill.Size = UDim2.fromScale(1, 1)
        fill.BackgroundColor3 = fillCol
        fill.BorderSizePixel = 0
        fill.Parent = bg
        return fill, lbl
    end

    self.HPBarFill = makeBar(12, "VIDA", Color3.fromRGB(65, 240, 140))
    self.ShieldBarFill = makeBar(36, "ESCUDO", Color3.fromRGB(55, 195, 255))
    self.StaminaBarFill = makeBar(60, "ENERGIA", Color3.fromRGB(255, 200, 55))
    self.OxygenBarFill = makeBar(84, "OXIGÊNIO", Color3.fromRGB(130, 240, 255))
    self.XPBarFill, self.LevelLabel = makeBar(110, "NV 1", Color3.fromRGB(195, 110, 255))

    -- Altímetro e Velocímetro Lateral
    local telemetry = self:CreateStyledFrame({
        Name = "TelemetryPanel",
        Size = UDim2.fromOffset(230, 58),
        Position = UDim2.new(0, 14, 0, 212),
        Parent = parent
    })

    local teleText = Instance.new("TextLabel")
    teleText.Size = UDim2.new(1, -16, 1, -8)
    teleText.Position = UDim2.fromOffset(8, 4)
    teleText.BackgroundTransparency = 1
    teleText.Font = Enum.Font.Code
    teleText.TextSize = 12
    teleText.TextXAlignment = Enum.TextXAlignment.Left
    teleText.TextColor3 = CONFIG.UI.TextColor
    teleText.Text = "ALT: 0 m | VEL: 0 m/s\nSETOR: TERRA PRIME"
    teleText.Parent = telemetry
    self.TelemetryLabel = teleText

    -- Botões Rápidos de Painéis (Auras, Mapa Estelar, Missões, Config)
    local topBtns = {
        { Name = "AURAS",    Modal = "Inventory" },
        { Name = "MAPA 2D",  Modal = "StarMap" },
        { Name = "MISSÕES",  Modal = "Missions" },
        { Name = "OPÇÕES",   Modal = "Settings" },
    }
    for i, b in ipairs(topBtns) do
        self:CreateButton({
            Name = "MenuBtn_" .. b.Modal,
            Text = b.Name,
            Size = UDim2.fromOffset(86, 36),
            Position = UDim2.new(1, -14 - (4 - i) * 92, 0, 14),
            AnchorPoint = Vector2.new(1, 0),
            TextSize = 11,
            Parent = parent,
            OnClick = function()
                self:ToggleModal(b.Modal)
            end
        })
    end
end

function HUD:BuildRadar(parent)
    local radar = self:CreateStyledFrame({
        Name = "RadarMinimap",
        Size = UDim2.fromOffset(136, 136),
        Position = UDim2.new(1, -14, 0, 60),
        AnchorPoint = Vector2.new(1, 0),
        Corner = 68,
        Parent = parent
    })
    self.RadarFrame = radar

    local centerDot = Instance.new("Frame")
    centerDot.Size = UDim2.fromOffset(6, 6)
    centerDot.Position = UDim2.fromScale(0.5, 0.5)
    centerDot.AnchorPoint = Vector2.new(0.5, 0.5)
    centerDot.BackgroundColor3 = Color3.new(1, 1, 1)
    centerDot.Parent = radar

    for i = 1, 18 do
        local dot = Instance.new("Frame")
        dot.Size = UDim2.fromOffset(5, 5)
        dot.AnchorPoint = Vector2.new(0.5, 0.5)
        dot.BorderSizePixel = 0
        dot.Visible = false
        dot.Parent = radar
        table.insert(self.RadarDots, dot)
    end
end

function HUD:BuildHotbar(parent)
    local hb = self:CreateStyledFrame({
        Name = "BottomHotbar",
        Size = UDim2.fromOffset(504, 56),
        Position = UDim2.new(0.5, 0, 1, -12),
        AnchorPoint = Vector2.new(0.5, 1),
        Parent = parent
    })

    local slotNames = {
        "1:VOO", "2:RIFLE", "3:PISTOLA", "4:CANHÃO", "5:ROLAR", "6:AUTO", "7:POUSAR", "8:MAPA", "9:SCAN"
    }

    for i = 1, 9 do
        local slotBtn = self:CreateButton({
            Name = "Slot_" .. i,
            Text = slotNames[i],
            Size = UDim2.fromOffset(50, 44),
            Position = UDim2.fromOffset(6 + (i - 1) * 55, 6),
            TextSize = 9,
            Parent = hb,
            OnClick = function()
                self:ActivateHotbarSlot(i)
            end
        })
        self.HotbarButtons[i] = slotBtn
    end
end

function HUD:ActivateHotbarSlot(slot)
    Cosmos.State.EquippedSlot = slot
    for i, btn in ipairs(self.HotbarButtons) do
        btn.BackgroundColor3 = (i == slot) and Color3.fromRGB(0, 110, 115) or CONFIG.UI.PanelColor
    end

    if slot == 1 then
        CombatFPS:SetEquipped(false)
        Flight:Toggle()
    elseif slot == 2 or slot == 3 or slot == 4 then
        CombatFPS:SelectWeapon(slot - 1)
        CombatFPS:SetEquipped(true)
    elseif slot == 5 then
        AuraRNG:TriggerRoll()
    elseif slot == 6 then
        Cosmos.State.AutoRoll = not Cosmos.State.AutoRoll
        self:Notify("AUTO-ROLL", Cosmos.State.AutoRoll and "Ativado!" or "Desativado!", CONFIG.UI.AccentColor)
    elseif slot == 7 then
        if Cosmos.State.WalkingOnPlanet then
            PlanetWalk:TakeOff()
        elseif Cosmos.State.NearestBody and Cosmos.State.NearestBody.Def.Walkable and Cosmos.State.NearestDist < 120 then
            PlanetWalk:Engage(Cosmos.State.NearestBody)
        else
            self:Notify("COMPUTADOR DE POUSO", "Aproxime-se a menos de 120m de uma lua ou planeta caminhável.", CONFIG.UI.WarnColor)
        end
    elseif slot == 8 then
        self:ToggleModal("StarMap")
    elseif slot == 9 then
        local nb = Cosmos.State.NearestBody
        if nb then
            self:Notify("SCANNER: " .. nb.Def.Name, nb.Def.Description or "Corpo celeste catalogado.", CONFIG.UI.AccentColor)
        end
    end
end

function HUD:BuildCrosshairAndWeaponHUD(parent)
    local ch = Instance.new("Frame")
    ch.Name = "Crosshair"
    ch.Size = UDim2.fromOffset(24, 24)
    ch.Position = UDim2.fromScale(0.5, 0.5)
    ch.AnchorPoint = Vector2.new(0.5, 0.5)
    ch.BackgroundTransparency = 1
    ch.Parent = parent
    self.Crosshair = ch

    local dot = Instance.new("Frame")
    dot.Size = UDim2.fromOffset(4, 4)
    dot.Position = UDim2.fromScale(0.5, 0.5)
    dot.AnchorPoint = Vector2.new(0.5, 0.5)
    dot.BackgroundColor3 = CONFIG.UI.AccentColor
    dot.BorderSizePixel = 0
    dot.Parent = ch

    local hm = Instance.new("TextLabel")
    hm.Size = UDim2.fromOffset(30, 30)
    hm.Position = UDim2.fromScale(0.5, 0.5)
    hm.AnchorPoint = Vector2.new(0.5, 0.5)
    hm.BackgroundTransparency = 1
    hm.Font = Enum.Font.GothamBold
    hm.TextSize = 20
    hm.TextColor3 = Color3.fromRGB(255, 70, 70)
    hm.Text = "✕"
    hm.Visible = false
    hm.Parent = ch
    self.HitmarkerLabel = hm

    -- Painel de Munição e Arma no canto inferior direito
    local wepPanel = self:CreateStyledFrame({
        Name = "WeaponStatusPanel",
        Size = UDim2.fromOffset(185, 58),
        Position = UDim2.new(1, -14, 1, -76),
        AnchorPoint = Vector2.new(1, 1),
        Parent = parent
    })

    local wepLbl = Instance.new("TextLabel")
    wepLbl.Size = UDim2.new(1, -16, 1, -8)
    wepLbl.Position = UDim2.fromOffset(8, 4)
    wepLbl.BackgroundTransparency = 1
    wepLbl.Font = Enum.Font.Code
    wepLbl.TextSize = 13
    wepLbl.TextXAlignment = Enum.TextXAlignment.Right
    wepLbl.TextColor3 = CONFIG.UI.TextColor
    wepLbl.Text = "RIFLE VX-9\n32 / 192"
    wepLbl.Parent = wepPanel
    self.WeaponStatusLbl = wepLbl

    -- Dica de Contexto no Centro-Baixo
    local ctx = Instance.new("TextLabel")
    ctx.Size = UDim2.fromOffset(360, 26)
    ctx.Position = UDim2.new(0.5, 0, 1, -82)
    ctx.AnchorPoint = Vector2.new(0.5, 1)
    ctx.BackgroundTransparency = 1
    ctx.Font = Enum.Font.GothamBold
    ctx.TextSize = 13
    ctx.TextColor3 = CONFIG.UI.AccentColor
    ctx.Text = ""
    ctx.Parent = parent
    self.ContextHintLbl = ctx
end

function HUD:TriggerHitmarker(isHeadshot)
    self.HitmarkerTimer = CONFIG.Combat.HitmarkerDuration
    if self.HitmarkerLabel then
        self.HitmarkerLabel.Visible = true
        self.HitmarkerLabel.TextColor3 = isHeadshot and Color3.fromRGB(255, 215, 45) or Color3.fromRGB(255, 75, 75)
    end
end

function HUD:BuildMobileTouchControls(parent)
    -- Joystick Virtual Esquerdo para Delta Mobile / Telas Touch (e arrasto de mouse opcional)
    local joyBase = self:CreateStyledFrame({
        Name = "VirtualJoystickBase",
        Size = UDim2.fromOffset(124, 124),
        Position = UDim2.new(0, 26, 1, -92),
        AnchorPoint = Vector2.new(0, 1),
        Corner = 62,
        Transparency = 0.45,
        Parent = parent
    })

    local joyKnob = self:CreateStyledFrame({
        Name = "JoystickKnob",
        Size = UDim2.fromOffset(50, 50),
        Position = UDim2.fromScale(0.5, 0.5),
        AnchorPoint = Vector2.new(0.5, 0.5),
        Corner = 25,
        Color = CONFIG.UI.AccentColor,
        Transparency = 0.2,
        Parent = joyBase
    })

    local draggingJoy = false
    local joyTouchObj = nil

    local function updateJoystick(inputPos)
        local center = joyBase.AbsolutePosition + joyBase.AbsoluteSize * 0.5
        local delta = Vector2.new(inputPos.X - center.X, inputPos.Y - center.Y)
        local maxR = joyBase.AbsoluteSize.X * 0.42
        if delta.Magnitude > maxR then
            delta = delta.Unit * maxR
        end
        joyKnob.Position = UDim2.new(0.5, delta.X, 0.5, delta.Y)
        Cosmos.State.TouchInputs.MoveVector = Vector3.new(delta.X / maxR, delta.Y / maxR, 0)
    end

    self.Maid:Add(joyBase.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.Touch or inp.UserInputType == Enum.UserInputType.MouseButton1 then
            draggingJoy = true
            joyTouchObj = inp
            updateJoystick(inp.Position)
        end
    end))

    self.Maid:Add(Services.UserInputService.InputChanged:Connect(function(inp)
        if draggingJoy and inp == joyTouchObj then
            updateJoystick(inp.Position)
        end
    end))

    self.Maid:Add(Services.UserInputService.InputEnded:Connect(function(inp)
        if draggingJoy and inp == joyTouchObj then
            draggingJoy = false
            joyTouchObj = nil
            joyKnob.Position = UDim2.fromScale(0.5, 0.5)
            Cosmos.State.TouchInputs.MoveVector = Vector3.zero
        end
    end))

    -- Cluster de Botões Mobile no Lado Direito (mínimo 52x52 px para ergonomia mobile no Delta)
    local function makeHoldButton(name, text, pos, onDown, onUp, col)
        local b = self:CreateButton({
            Name = name,
            Text = text,
            Size = UDim2.fromOffset(64, 52),
            Position = pos,
            AnchorPoint = Vector2.new(1, 1),
            Color = col or CONFIG.UI.PanelColor,
            TextSize = 11,
            Parent = parent
        })
        self.Maid:Add(b.InputBegan:Connect(function(inp)
            if inp.UserInputType == Enum.UserInputType.Touch or inp.UserInputType == Enum.UserInputType.MouseButton1 then
                if onDown then onDown() end
            end
        end))
        self.Maid:Add(b.InputEnded:Connect(function(inp)
            if inp.UserInputType == Enum.UserInputType.Touch or inp.UserInputType == Enum.UserInputType.MouseButton1 then
                if onUp then onUp() end
            end
        end))
        return b
    end

    -- Coluna 1 (Extrema Direita): SUBIR, DESCER, TURBO/VEL, VOAR
    makeHoldButton("BtnAscend", "▲ SUBIR", UDim2.new(1, -14, 1, -260), function()
        Cosmos.State.TouchInputs.Ascend = true
    end, function()
        Cosmos.State.TouchInputs.Ascend = false
    end)

    makeHoldButton("BtnDescend", "▼ DESCER", UDim2.new(1, -14, 1, -200), function()
        Cosmos.State.TouchInputs.Descend = true
    end, function()
        Cosmos.State.TouchInputs.Descend = false
    end)

    self:CreateButton({
        Name = "BtnTurboMode",
        Text = "⚡ TURBO",
        Size = UDim2.fromOffset(64, 52),
        Position = UDim2.new(1, -86, 1, -260),
        AnchorPoint = Vector2.new(1, 1),
        TextSize = 11,
        Parent = parent,
        OnClick = function()
            Flight:CycleFlightMode()
        end
    })

    self:CreateButton({
        Name = "BtnFlyToggle",
        Text = "🚀 VOAR",
        Size = UDim2.fromOffset(64, 52),
        Position = UDim2.new(1, -86, 1, -200),
        AnchorPoint = Vector2.new(1, 1),
        TextSize = 11,
        Parent = parent,
        OnClick = function()
            Flight:Toggle()
        end
    })

    -- Coluna 2 (Combate & Auras): ATIRAR, MIRAR, RECARREGAR, ROLAR AURA
    makeHoldButton("BtnFire", "🔥 ATIRAR", UDim2.new(1, -158, 1, -200), function()
        if not CombatFPS.Enabled then CombatFPS:SetEquipped(true) end
        Cosmos.State.TouchInputs.Fire = true
    end, function()
        Cosmos.State.TouchInputs.Fire = false
    end, Color3.fromRGB(65, 22, 28))

    self:CreateButton({
        Name = "BtnADS",
        Text = "🎯 MIRAR",
        Size = UDim2.fromOffset(64, 52),
        Position = UDim2.new(1, -158, 1, -260),
        AnchorPoint = Vector2.new(1, 1),
        TextSize = 11,
        Parent = parent,
        OnClick = function()
            if not CombatFPS.Enabled then CombatFPS:SetEquipped(true) end
            Cosmos.State.Aiming = not Cosmos.State.Aiming
        end
    })

    self:CreateButton({
        Name = "BtnReload",
        Text = "🔄 RECARGA",
        Size = UDim2.fromOffset(64, 52),
        Position = UDim2.new(1, -230, 1, -200),
        AnchorPoint = Vector2.new(1, 1),
        TextSize = 10,
        Parent = parent,
        OnClick = function()
            CombatFPS:StartReload()
        end
    })

    self:CreateButton({
        Name = "BtnRollAura",
        Text = "✨ AURA",
        Size = UDim2.fromOffset(64, 52),
        Position = UDim2.new(1, -230, 1, -260),
        AnchorPoint = Vector2.new(1, 1),
        Color = Color3.fromRGB(36, 18, 56),
        TextSize = 11,
        Parent = parent,
        OnClick = function()
            AuraRNG:TriggerRoll()
        end
    })
end

function HUD:BuildNotificationStack(sg)
    local stack = Instance.new("Frame")
    stack.Name = "NotificationStack"
    stack.Size = UDim2.fromOffset(310, 260)
    stack.Position = UDim2.new(0.5, 0, 0, 62)
    stack.AnchorPoint = Vector2.new(0.5, 0)
    stack.BackgroundTransparency = 1
    stack.Parent = sg
    self.NotifyStack = stack

    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 6)
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    layout.Parent = stack
end

function HUD:Notify(title, text, accentColor)
    if not self.NotifyStack then return end
    local card = self:CreateStyledFrame({
        Size = UDim2.fromOffset(300, 52),
        StrokeColor = accentColor or CONFIG.UI.StrokeColor,
        Parent = self.NotifyStack
    })

    local tLbl = Instance.new("TextLabel")
    tLbl.Size = UDim2.new(1, -16, 0, 20)
    tLbl.Position = UDim2.fromOffset(8, 4)
    tLbl.BackgroundTransparency = 1
    tLbl.Font = Enum.Font.GothamBold
    tLbl.TextSize = 12
    tLbl.TextXAlignment = Enum.TextXAlignment.Left
    tLbl.TextColor3 = accentColor or CONFIG.UI.AccentColor
    tLbl.Text = title
    tLbl.Parent = card

    local bLbl = Instance.new("TextLabel")
    bLbl.Size = UDim2.new(1, -16, 0, 24)
    bLbl.Position = UDim2.fromOffset(8, 24)
    bLbl.BackgroundTransparency = 1
    bLbl.Font = Enum.Font.Gotham
    bLbl.TextSize = 11
    bLbl.TextWrapped = true
    bLbl.TextXAlignment = Enum.TextXAlignment.Left
    bLbl.TextColor3 = CONFIG.UI.TextColor
    bLbl.Text = text
    bLbl.Parent = card

    task.delay(4.2, function()
        if card and card.Parent then
            Util.Tween(card, 0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, { BackgroundTransparency = 1 })
            task.wait(0.35)
            pcall(function() card:Destroy() end)
        end
    end)
end

function HUD:BuildModals(sg)
    -- 1. Modal de Inventário/Coleção de Auras
    local inv = self:CreateStyledFrame({
        Name = "InventoryModal",
        Size = UDim2.fromOffset(560, 360),
        Position = UDim2.fromScale(0.5, 0.5),
        AnchorPoint = Vector2.new(0.5, 0.5),
        Parent = sg
    })
    inv.Visible = false
    self.Modals.Inventory = inv

    local invTitle = Instance.new("TextLabel")
    invTitle.Size = UDim2.new(1, -20, 0, 32)
    invTitle.Position = UDim2.fromOffset(12, 8)
    invTitle.BackgroundTransparency = 1
    invTitle.Font = Enum.Font.GothamBold
    invTitle.TextSize = 16
    invTitle.TextXAlignment = Enum.TextXAlignment.Left
    invTitle.TextColor3 = CONFIG.UI.AccentColor
    invTitle.Text = "COLEÇÃO DE AURAS CÓSMICAS (24)"
    invTitle.Parent = inv

    local scroll = Instance.new("ScrollingFrame")
    scroll.Size = UDim2.new(1, -24, 1, -56)
    scroll.Position = UDim2.fromOffset(12, 44)
    scroll.BackgroundTransparency = 1
    scroll.ScrollBarThickness = 6
    scroll.CanvasSize = UDim2.fromOffset(0, 520)
    scroll.Parent = inv
    self.AuraGridScroll = scroll

    local grid = Instance.new("UIGridLayout")
    grid.CellSize = UDim2.fromOffset(126, 56)
    grid.CellPadding = UDim2.fromOffset(8, 8)
    grid.Parent = scroll

    self.AuraCards = {}
    for _, aura in ipairs(AURAS) do
        local r = RARITIES[aura.Tier]
        local c = self:CreateButton({
            Name = "AuraCard_" .. aura.Id,
            Text = "???\n1 in " .. Util.FormatNumber(aura.Odds),
            Size = UDim2.fromOffset(126, 56),
            StrokeColor = r.Color,
            TextSize = 10,
            Parent = scroll,
            OnClick = function()
                if Cosmos.State.UnlockedAuras[aura.Id] then
                    if Cosmos.State.EquippedAura == aura.Id then
                        AuraRNG:EquipAura(nil)
                    else
                        AuraRNG:EquipAura(aura.Id)
                    end
                    self:RefreshInventoryModal()
                end
            end
        })
        self.AuraCards[aura.Id] = c
    end

    -- 2. Modal de Mapa Estelar 2D com Teleporte Direto
    local smap = self:CreateStyledFrame({
        Name = "StarMapModal",
        Size = UDim2.fromOffset(540, 350),
        Position = UDim2.fromScale(0.5, 0.5),
        AnchorPoint = Vector2.new(0.5, 0.5),
        Parent = sg
    })
    smap.Visible = false
    self.Modals.StarMap = smap

    local mapTitle = Instance.new("TextLabel")
    mapTitle.Size = UDim2.new(1, -20, 0, 32)
    mapTitle.Position = UDim2.fromOffset(12, 8)
    mapTitle.BackgroundTransparency = 1
    mapTitle.Font = Enum.Font.GothamBold
    mapTitle.TextSize = 16
    mapTitle.TextXAlignment = Enum.TextXAlignment.Left
    mapTitle.TextColor3 = CONFIG.UI.AccentColor
    mapTitle.Text = "MAPA ESTELAR & NAVEGAÇÃO DE HIPERSALTO"
    mapTitle.Parent = smap

    local allBodies = Universe:GetAllBodiesList()
    for idx, b in ipairs(allBodies) do
        local col = (idx - 1) % 3
        local row = math.floor((idx - 1) / 3)
        self:CreateButton({
            Name = "Warp_" .. b.Def.Id,
            Text = "⚡ " .. b.Def.Name .. (b.IsMoon and " (Lua)" or ""),
            Size = UDim2.fromOffset(162, 46),
            Position = UDim2.fromOffset(16 + col * 172, 52 + row * 56),
            StrokeColor = b.Def.Color,
            TextSize = 11,
            Parent = smap,
            OnClick = function()
                local _, hrp = Util.GetCharacter()
                if hrp then
                    hrp.CFrame = CFrame.new(b.Position + Vector3.new(0, b.Def.Radius + 95, 0))
                    CameraFX:Flash(b.Def.Color, 0.65)
                    Audio:Play("SonicBoom", 1.25, 0.8)
                    self:ToggleModal("StarMap")
                end
            end
        })
    end

    -- 3. Modal de Missões e Conquistas
    local mModal = self:CreateStyledFrame({
        Name = "MissionsModal",
        Size = UDim2.fromOffset(540, 350),
        Position = UDim2.fromScale(0.5, 0.5),
        AnchorPoint = Vector2.new(0.5, 0.5),
        Parent = sg
    })
    mModal.Visible = false
    self.Modals.Missions = mModal

    local mText = Instance.new("TextLabel")
    mText.Size = UDim2.new(1, -24, 1, -24)
    mText.Position = UDim2.fromOffset(12, 12)
    mText.BackgroundTransparency = 1
    mText.Font = Enum.Font.Code
    mText.TextSize = 12
    mText.TextXAlignment = Enum.TextXAlignment.Left
    mText.TextYAlignment = Enum.TextYAlignment.Top
    mText.TextColor3 = CONFIG.UI.TextColor
    mText.Parent = mModal
    self.MissionsTextLbl = mText

    -- 4. Modal de Opções / Qualidade / Desinstalar
    local sModal = self:CreateStyledFrame({
        Name = "SettingsModal",
        Size = UDim2.fromOffset(420, 310),
        Position = UDim2.fromScale(0.5, 0.5),
        AnchorPoint = Vector2.new(0.5, 0.5),
        Parent = sg
    })
    sModal.Visible = false
    self.Modals.Settings = sModal

    self.QualityBtn = self:CreateButton({
        Text = "QUALIDADE GRÁFICA: ALTA",
        Size = UDim2.fromOffset(380, 44),
        Position = UDim2.fromOffset(20, 24),
        Parent = sModal,
        OnClick = function()
            Cosmos.DynamicQuality = false
            local nextQ = (Cosmos.QualityLevel % 3) + 1
            QualityMgr:SetQuality(nextQ)
        end
    })

    self:CreateButton({
        Text = "ALTERNAR ÁUDIO (MUTE / UNMUTE)",
        Size = UDim2.fromOffset(380, 44),
        Position = UDim2.fromOffset(20, 80),
        Parent = sModal,
        OnClick = function()
            Audio.Enabled = not Audio.Enabled
            self:Notify("ÁUDIO", Audio.Enabled and "Sons ativados." or "Sons silenciados.", CONFIG.UI.AccentColor)
        end
    })

    self:CreateButton({
        Text = "ALTERNAR ECONOMIA DE BATERIA",
        Size = UDim2.fromOffset(380, 44),
        Position = UDim2.fromOffset(20, 136),
        Parent = sModal,
        OnClick = function()
            Cosmos.BatterySaver = not Cosmos.BatterySaver
            if Cosmos.BatterySaver then QualityMgr:SetQuality(1) end
            self:Notify("BATERIA", Cosmos.BatterySaver and "Modo Economia Ativo." or "Modo Performance Normal.", CONFIG.UI.WarnColor)
        end
    })

    self:CreateButton({
        Text = "ALTERNAR OVERLAY DE DEBUG (FPS/PARTS)",
        Size = UDim2.fromOffset(380, 44),
        Position = UDim2.fromOffset(20, 192),
        Parent = sModal,
        OnClick = function()
            Cosmos.DebugVisible = not Cosmos.DebugVisible
            if self.DebugOverlay then self.DebugOverlay.Visible = Cosmos.DebugVisible end
        end
    })

    self:CreateButton({
        Text = "DESINSTALAR COSMOS ODYSSEY (_G.__CosmosCleanup)",
        Size = UDim2.fromOffset(380, 44),
        Position = UDim2.fromOffset(20, 248),
        Color = Color3.fromRGB(85, 20, 28),
        StrokeColor = CONFIG.UI.DangerColor,
        Parent = sModal,
        OnClick = function()
            if _G.__CosmosCleanup then _G.__CosmosCleanup() end
        end
    })

    -- Overlay de Debug Opcional
    local dbg = self:CreateStyledFrame({
        Name = "DebugOverlay",
        Size = UDim2.fromOffset(230, 68),
        Position = UDim2.new(0, 14, 0, 278),
        Parent = sg
    })
    dbg.Visible = false
    self.DebugOverlay = dbg

    local dbgLbl = Instance.new("TextLabel")
    dbgLbl.Size = UDim2.new(1, -12, 1, -8)
    dbgLbl.Position = UDim2.fromOffset(6, 4)
    dbgLbl.BackgroundTransparency = 1
    dbgLbl.Font = Enum.Font.Code
    dbgLbl.TextSize = 11
    dbgLbl.TextXAlignment = Enum.TextXAlignment.Left
    dbgLbl.TextColor3 = CONFIG.UI.AccentColor
    dbgLbl.Parent = dbg
    self.DebugLabel = dbgLbl
end

function HUD:UpdateQualityLabel(qName)
    if self.QualityBtn then
        self.QualityBtn.Text = "QUALIDADE GRÁFICA: " .. qName
    end
end

function HUD:RefreshInventoryModal()
    for _, aura in ipairs(AURAS) do
        local btn = self.AuraCards[aura.Id]
        if btn then
            if Cosmos.State.UnlockedAuras[aura.Id] then
                local eq = (Cosmos.State.EquippedAura == aura.Id) and " [EQUIPADA]" or ""
                local cnt = Cosmos.State.AuraCounts[aura.Id] or 1
                btn.Text = aura.Name .. eq .. "\n1 in " .. Util.FormatNumber(aura.Odds) .. " (x" .. cnt .. ")"
            else
                btn.Text = "???\n1 in " .. Util.FormatNumber(aura.Odds)
            end
        end
    end
end

function HUD:RefreshMissionsModal()
    if not self.MissionsTextLbl then return end
    local lines = { "=== MISSÕES ATIVAS (SESSÃO) ===" }
    for _, m in ipairs(MISSIONS) do
        local done = Cosmos.State.CompletedMissions[m.Id]
        local p = Missions.Progress[m.Id] or 0
        local status = done and "[CONCLUÍDA]" or string.format("[%d/%d]", math.min(p, m.Goal), m.Goal)
        table.insert(lines, string.format("%s %s - %s", status, m.Title, m.Desc))
    end
    table.insert(lines, "\n=== CONQUISTAS ===")
    for _, a in ipairs(ACHIEVEMENTS) do
        local unl = Cosmos.State.UnlockedAchievements[a.Id] and "[★]" or "[ ]"
        table.insert(lines, string.format("%s %s - %s", unl, a.Title, a.Desc))
    end
    self.MissionsTextLbl.Text = table.concat(lines, "\n")
end

function HUD:ToggleModal(name)
    for k, m in pairs(self.Modals) do
        if k == name then
            m.Visible = not m.Visible
            if m.Visible then
                if k == "Inventory" then self:RefreshInventoryModal() end
                if k == "Missions" then self:RefreshMissionsModal() end
            end
        else
            m.Visible = false
        end
    end
end

function HUD:BuildAuraCinematicOverlay(sg)
    local ov = Instance.new("Frame")
    ov.Name = "AuraRevealOverlay"
    ov.Size = UDim2.fromScale(1, 1)
    ov.BackgroundColor3 = Color3.fromRGB(6, 12, 18)
    ov.BackgroundTransparency = 0.25
    ov.Visible = false
    ov.ZIndex = 70
    ov.Parent = sg
    self.AuraOverlay = ov

    local rLbl = Instance.new("TextLabel")
    rLbl.Size = UDim2.new(1, 0, 0, 54)
    rLbl.Position = UDim2.new(0.5, 0, 0.36, 0)
    rLbl.AnchorPoint = Vector2.new(0.5, 0.5)
    rLbl.BackgroundTransparency = 1
    rLbl.Font = Enum.Font.GothamBlack
    rLbl.TextSize = 38
    rLbl.TextColor3 = Color3.new(1, 1, 1)
    rLbl.Text = " CANALIZANDO ENERGIA CÓSMICA... "
    rLbl.ZIndex = 72
    rLbl.Parent = ov
    self.AuraTierLbl = rLbl

    local nLbl = Instance.new("TextLabel")
    nLbl.Size = UDim2.new(1, 0, 0, 44)
    nLbl.Position = UDim2.new(0.5, 0, 0.48, 0)
    nLbl.AnchorPoint = Vector2.new(0.5, 0.5)
    nLbl.BackgroundTransparency = 1
    nLbl.Font = Enum.Font.Code
    nLbl.TextSize = 24
    nLbl.TextColor3 = CONFIG.UI.AccentColor
    nLbl.Text = ""
    nLbl.ZIndex = 72
    nLbl.Parent = ov
    self.AuraNameLbl = nLbl

    local skipBtn = self:CreateButton({
        Text = "PULAR ANIMAÇÃO (SKIP)",
        Size = UDim2.fromOffset(190, 46),
        Position = UDim2.new(0.5, 0, 0.82, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        Parent = ov,
        OnClick = function()
            AuraRNG:SkipCinematic()
        end
    })
    skipBtn.ZIndex = 75
end

function HUD:StartAuraCinematic(_chosen, rarity)
    if not self.AuraOverlay then return end
    self.AuraOverlay.Visible = true
    self.AuraOverlay.BackgroundColor3 = rarity.BgColor
    self.AuraTierLbl.TextColor3 = Color3.fromRGB(220, 240, 255)
    self.AuraTierLbl.Text = "✦ SINCRONIZANDO SINGULARIDADE... ✦"
    self.AuraNameLbl.Text = "Aguarde a revelação..."
end

function HUD:ShowAuraRevealResult(chosen, rarity)
    if not self.AuraOverlay then return end
    self.AuraTierLbl.TextColor3 = rarity.Color
    self.AuraTierLbl.Text = "★ " .. rarity.Name .. " ★"
    self.AuraNameLbl.Text = chosen.Name .. "  [ 1 in " .. Util.FormatNumber(chosen.Odds) .. " ]"
end

function HUD:EndAuraCinematic()
    if self.AuraOverlay then
        self.AuraOverlay.Visible = false
    end
end

function HUD:BuildStartScreen(sg)
    local startFrame = self:CreateStyledFrame({
        Name = "StartScreen",
        Size = UDim2.fromScale(1, 1),
        Color = Color3.fromRGB(4, 12, 18),
        Transparency = 0.25,
        NoStroke = true,
        Parent = sg
    })
    startFrame.ZIndex = 80
    self.StartScreen = startFrame

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 64)
    title.Position = UDim2.new(0.5, 0, 0.34, 0)
    title.AnchorPoint = Vector2.new(0.5, 0.5)
    title.BackgroundTransparency = 1
    title.Font = Enum.Font.GothamBlack
    title.TextSize = 46
    title.TextColor3 = CONFIG.UI.AccentColor
    title.Text = "COSMOS ODYSSEY"
    title.ZIndex = 82
    title.Parent = startFrame

    local sub = Instance.new("TextLabel")
    sub.Size = UDim2.new(1, 0, 0, 32)
    sub.Position = UDim2.new(0.5, 0, 0.43, 0)
    sub.AnchorPoint = Vector2.new(0.5, 0.5)
    sub.BackgroundTransparency = 1
    sub.Font = Enum.Font.Code
    sub.TextSize = 15
    sub.TextColor3 = CONFIG.UI.TextColor
    sub.Text = "EXPLORAÇÃO ESPACIAL • VOO SUPERMAN • AURA RNG • COMBATE FPS"
    sub.ZIndex = 82
    sub.Parent = startFrame

    local playBtn = self:CreateButton({
        Name = "BtnStartOdyssey",
        Text = "▶ INICIAR ODISSEIA",
        Size = UDim2.fromOffset(250, 56),
        Position = UDim2.new(0.5, 0, 0.60, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        TextSize = 17,
        Parent = startFrame,
        OnClick = function()
            Cosmos.Started = true
            CameraFX.IntroActive = false
            startFrame.Visible = false
            self.GameplayHUD.Visible = true
            self:Notify("BEM-VINDO À ODISSEIA", "Use o botão VOAR (ou tecla F) para decolar rumo ao espaço!", CONFIG.UI.AccentColor)
        end
    })
    playBtn.ZIndex = 83
end

function HUD:SetupKeyboardShortcuts()
    self.Maid:Add(Services.UserInputService.InputBegan:Connect(function(inp, gpe)
        if gpe or not Cosmos.Started then return end
        local kc = inp.KeyCode
        if kc == Enum.KeyCode.F then
            Flight:Toggle()
        elseif kc == Enum.KeyCode.R then
            if CombatFPS.Enabled then CombatFPS:StartReload() else AuraRNG:TriggerRoll() end
        elseif kc == Enum.KeyCode.G then
            Flight:CycleFlightMode()
        elseif kc == Enum.KeyCode.M then
            self:ToggleModal("StarMap")
        elseif kc == Enum.KeyCode.One then self:ActivateHotbarSlot(1)
        elseif kc == Enum.KeyCode.Two then self:ActivateHotbarSlot(2)
        elseif kc == Enum.KeyCode.Three then self:ActivateHotbarSlot(3)
        elseif kc == Enum.KeyCode.Four then self:ActivateHotbarSlot(4)
        elseif kc == Enum.KeyCode.Five then self:ActivateHotbarSlot(5)
        elseif kc == Enum.KeyCode.Six then self:ActivateHotbarSlot(6)
        elseif kc == Enum.KeyCode.Seven then self:ActivateHotbarSlot(7)
        elseif kc == Enum.KeyCode.Eight then self:ActivateHotbarSlot(8)
        elseif kc == Enum.KeyCode.Nine then self:ActivateHotbarSlot(9)
        end

        if inp.UserInputType == Enum.UserInputType.MouseButton1 and CombatFPS.Enabled then
            Cosmos.State.Shooting = true
        elseif inp.UserInputType == Enum.UserInputType.MouseButton2 and CombatFPS.Enabled then
            Cosmos.State.Aiming = true
        end
    end))

    self.Maid:Add(Services.UserInputService.InputEnded:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 then
            Cosmos.State.Shooting = false
        elseif inp.UserInputType == Enum.UserInputType.MouseButton2 then
            Cosmos.State.Aiming = false
        end
    end))
end

function HUD:Update(dt)
    if not self.ScreenGui then return end

    -- Escala responsiva automática para celulares e PCs
    local vp = Camera and Camera.ViewportSize or Vector2.new(1280, 720)
    self.UIScale.Scale = Util.Clamp(math.min(vp.X / 1150, vp.Y / 680), 0.68, 1.12)

    -- Atualizar Flash de Tela
    if self.FlashFrame then
        self.FlashFrame.BackgroundColor3 = CameraFX.FlashColor
        self.FlashFrame.BackgroundTransparency = 1 - CameraFX.FlashAlpha
    end

    if self.HitmarkerTimer > 0 then
        self.HitmarkerTimer = math.max(0, self.HitmarkerTimer - dt)
        if self.HitmarkerTimer <= 0 and self.HitmarkerLabel then
            self.HitmarkerLabel.Visible = false
        end
    end

    if not Cosmos.Started then return end

    -- 1. Atualizar Bússola Superior e Marcadores de Planetas
    local camCF = Camera and Camera.CFrame or CFrame.identity
    local look = camCF.LookVector
    local heading = (math.deg(math.atan2(-look.X, -look.Z)) + 360) % 360
    local dirs = { "N", "NE", "L", "SE", "S", "SO", "O", "NO" }
    local dIdx = (math.floor((heading + 22.5) / 45) % 8) + 1
    self.CompassHeadingLbl.Text = string.format("%03d° %s", math.floor(heading), dirs[dIdx])

    local camPos = camCF.Position
    for _, item in pairs(self.CompassMarkers) do
        local bPos = item.Body.Position
        local toB = (bPos - camPos)
        local flatAng = math.deg(math.atan2(-toB.X, -toB.Z))
        local diff = ((flatAng - heading + 540) % 360) - 180
        if math.abs(diff) <= 75 then
            item.Label.Visible = true
            local normX = 0.5 + (diff / 150)
            local distKm = math.floor(toB.Magnitude / 100) / 10
            item.Label.Position = UDim2.new(normX, 0, 0, 20)
            item.Label.Text = string.format("◆ %s (%.1fkm)", item.Body.Def.Name, distKm)
        else
            item.Label.Visible = false
        end
    end

    -- 2. Atualizar Barras de Status e Telemetria
    local st = Cosmos.State
    self.HPBarFill.Size = UDim2.fromScale(Util.Clamp(st.Health / st.MaxHealth, 0, 1), 1)
    self.ShieldBarFill.Size = UDim2.fromScale(Util.Clamp(st.Shield / st.MaxShield, 0, 1), 1)
    self.StaminaBarFill.Size = UDim2.fromScale(Util.Clamp(st.Stamina / st.MaxStamina, 0, 1), 1)
    self.OxygenBarFill.Size = UDim2.fromScale(Util.Clamp(st.Oxygen / st.MaxOxygen, 0, 1), 1)
    self.XPBarFill.Size = UDim2.fromScale(Util.Clamp(st.XP / (st.Level * 200), 0, 1), 1)
    self.LevelLabel.Text = "NV " .. st.Level

    local sectorName = st.NearestBody and st.NearestBody.Def.Name:upper() or "ESPAÇO PROFUNDO"
    local modeNames = { [1] = "NORMAL", [2] = "TURBO", [3] = "HIPER" }
    local fModeStr = st.Flying and (" [" .. modeNames[st.FlightMode] .. "]") or (st.WalkingOnPlanet and " [LUNAR WALK]" or "")
    self.TelemetryLabel.Text = string.format(
        "ALT: %s m | VEL: %d m/s%s\nSETOR: %s | LUCK: %.2fx",
        Util.FormatNumber(st.Altitude),
        math.floor(st.Speed),
        fModeStr,
        sectorName,
        AuraRNG:GetTotalLuck()
    )

    -- 3. Atualizar HUD de Arma e Dica de Contexto
    local w = WEAPONS[st.CurrentWeapon]
    local mag = CombatFPS.AmmoInMag[st.CurrentWeapon]
    local res = CombatFPS.AmmoReserve[st.CurrentWeapon]
    self.WeaponStatusLbl.Text = string.format(
        "%s\n%s",
        w.Name:upper(),
        CombatFPS.Reloading and "RECARREGANDO..." or string.format("%d / %d", mag, res)
    )

    if st.NearestBody and st.NearestBody.Def.Walkable and st.NearestDist < 120 and not st.WalkingOnPlanet then
        self.ContextHintLbl.Text = "[SLOT 7] Pousar em " .. st.NearestBody.Def.Name
    elseif st.WalkingOnPlanet then
        self.ContextHintLbl.Text = "[SLOT 7 / BOTÃO VOAR] Decolar da superfície"
    else
        self.ContextHintLbl.Text = ""
    end

    -- 4. Atualizar Radar 2D (Planetas e Drones Inimigos)
    local dotIdx = 1
    for _, b in ipairs(Universe.BodyRuntimes) do
        if dotIdx <= #self.RadarDots then
            local rel = camCF:PointToObjectSpace(b.Position)
            local rx = Util.Clamp(rel.X / 16000, -0.45, 0.45)
            local rz = Util.Clamp(rel.Z / 16000, -0.45, 0.45)
            local dot = self.RadarDots[dotIdx]
            dot.Visible = true
            dot.BackgroundColor3 = b.Def.Color
            dot.Position = UDim2.fromScale(0.5 + rx, 0.5 + rz)
            dotIdx = dotIdx + 1
        end
    end
    for _, en in ipairs(EnemyAI.ActiveEnemies) do
        if dotIdx <= #self.RadarDots then
            local rel = camCF:PointToObjectSpace(en.Position)
            local rx = Util.Clamp(rel.X / 500, -0.45, 0.45)
            local rz = Util.Clamp(rel.Z / 500, -0.45, 0.45)
            local dot = self.RadarDots[dotIdx]
            dot.Visible = true
            dot.BackgroundColor3 = Color3.fromRGB(255, 55, 65)
            dot.Position = UDim2.fromScale(0.5 + rx, 0.5 + rz)
            dotIdx = dotIdx + 1
        end
    end
    for i = dotIdx, #self.RadarDots do
        self.RadarDots[i].Visible = false
    end

    -- 5. Atualizar Debug Overlay
    if Cosmos.DebugVisible and self.DebugLabel then
        self.DebugLabel.Text = string.format(
            "FPS: %d | QUALIDADE: %d\nPARTS ATIVAS: %d | ROLLS: %d\nDRONES ATIVOS: %d",
            Cosmos.CurrentFPS,
            Cosmos.QualityLevel,
            Cosmos.ActivePartsCount,
            Cosmos.State.TotalRolls,
            #EnemyAI.ActiveEnemies
        )
    end
end

function HUD:Destroy()
    self.Maid:Clean()
end

--====================================================================================================
-- [SEÇÃO 17] MÓDULO 15: MAIN ORCHESTRATOR, RESPAWN HANDLER, RENDERSTEPPED ÚNICO & CLEANUP TOTAL
--====================================================================================================
local function SetupRespawnHandler()
    Cosmos.MasterMaid:Add(LocalPlayer.CharacterAdded:Connect(function(newChar)
        task.wait(0.35)
        if not Cosmos.Active then return end
        local hrp = newChar:WaitForChild("HumanoidRootPart", 5)
        if hrp then
            if Cosmos.State.Flying then
                Flight:EnsureMovers(hrp)
                Flight:AttachTrail(hrp)
            end
            if Cosmos.State.EquippedAura then
                AuraRNG:EquipAura(Cosmos.State.EquippedAura)
            end
        end
    end))
end

local function StartCosmosOdyssey()
    -- Inicializar todos os módulos com isolamento de erro via pcall
    for _, modName in ipairs(Cosmos.ModuleOrder) do
        local mod = Cosmos.Modules[modName]
        if mod and type(mod.Init) == "function" then
            local ok, err = pcall(function()
                mod:Init()
            end)
            if not ok then
                warn("[COSMOS ODYSSEY] Aviso no módulo " .. tostring(modName) .. ": " .. tostring(err))
            end
        end
    end

    SetupRespawnHandler()

    -- Único loop RenderStepped principal que despacha dt para todos os módulos
    Cosmos.MasterMaid:Add(Services.RunService.RenderStepped:Connect(function(dt)
        if not Cosmos.Active then return end
        dt = math.min(dt, 0.1)
        Cosmos.TimeElapsed = Cosmos.TimeElapsed + dt
        Cosmos.FrameCount = Cosmos.FrameCount + 1

        for i = 1, #Cosmos.ModuleOrder do
            local modName = Cosmos.ModuleOrder[i]
            local mod = Cosmos.Modules[modName]
            if mod and type(mod.Update) == "function" then
                local t0 = os.clock()
                pcall(mod.Update, mod, dt)
                Cosmos.ModuleTimings[modName] = (os.clock() - t0) * 1000
            end
        end
    end))
end

_G.__CosmosCleanup = function()
    Cosmos.Active = false
    for i = #Cosmos.ModuleOrder, 1, -1 do
        local modName = Cosmos.ModuleOrder[i]
        local mod = Cosmos.Modules[modName]
        if mod and type(mod.Destroy) == "function" then
            pcall(function() mod:Destroy() end)
        end
    end
    Cosmos.MasterMaid:Clean()
end

StartCosmosOdyssey()
