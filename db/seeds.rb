# This file grows small plants and feeds birds.
org1 = Organization.create(name: "Robots!", subdomain: "robots")
org2 = Organization.create(name: "Pirates", subdomain: "pirates")

User.new(name: "One Eyed Eduardo", email: "OlOneEye@example.com", organization_id: org1.id)
User.new(name: "Hooks for Hands Henry", email: "HooksForHandHenry@example.com", organization_id: org1.id)
User.new(name: "Beep Boop", email: "beepboop@example.com", organization_id: org2.id)
User.new(id: 4, name: "Hal", email: "HAL@example.com", organization_id: org2.id)