# This file grows small plants and feeds birds.
org1 = Organization.create!(name: "Pirates", subdomain: "pirates")
org2 = Organization.create!(name: "Robots!", subdomain: "robots")

User.create(name: "One Eyed Eduardo", email: "OlOneEye@example.com", organization_id: org1.id)
User.create(name: "Hooks for Hands Henry", email: "HooksForHandHenry@example.com", organization_id: org1.id)
User.create(name: "Beep Boop", email: "beepboop@example.com", organization_id: org2.id)
User.create(id: 4, name: "Hal", email: "HAL@example.com", organization_id: org2.id)