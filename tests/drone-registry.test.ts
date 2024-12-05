import { describe, it, expect, beforeEach } from 'vitest'

// Mock blockchain state
let drones: { [key: number]: any } = {}
let lastDroneId = 0

// Mock contract functions
const registerDrone = (sender: string, name: string, capabilities: string[]) => {
  lastDroneId++
  drones[lastDroneId] = {
    owner: sender,
    name,
    capabilities,
    status: "idle"
  }
  return { success: true, value: lastDroneId }
}

const updateDroneStatus = (sender: string, droneId: number, newStatus: string) => {
  if (!drones[droneId]) {
    return { success: false, error: 101 }
  }
  if (sender !== drones[droneId].owner) {
    return { success: false, error: 100 }
  }
  drones[droneId].status = newStatus
  return { success: true }
}

const getDrone = (droneId: number) => {
  return drones[droneId] || null
}

describe('DroneRegistry', () => {
  beforeEach(() => {
    drones = {}
    lastDroneId = 0
  })
  
  it('ensures drones can be registered and retrieved', () => {
    const user1 = 'ST2CY5V39NHDPWSXMW9QDT3HC3GD6Q6XX4CFRK9AG'
    
    const registerResult = registerDrone(
        user1,
        'Drone 1',
        ['camera', 'gps']
    )
    expect(registerResult.success).toBe(true)
    expect(registerResult.value).toBe(1)
    
    const droneInfo = getDrone(1)
    expect(droneInfo).toEqual({
      owner: user1,
      name: 'Drone 1',
      capabilities: ['camera', 'gps'],
      status: 'idle'
    })
    
    const updateResult = updateDroneStatus(user1, 1, 'active')
    expect(updateResult.success).toBe(true)
    
    const updatedDroneInfo = getDrone(1)
    expect(updatedDroneInfo.status).toBe('active')
  })
  
  it('ensures only the owner can update drone status', () => {
    const user1 = 'ST2CY5V39NHDPWSXMW9QDT3HC3GD6Q6XX4CFRK9AG'
    const user2 = 'ST2JHG361ZXG51QTKY2NQCVBPPRRE2KZB1HR05NNC'
    
    registerDrone(
        user1,
        'Drone 1',
        ['camera', 'gps']
    )
    
    const updateResult = updateDroneStatus(user2, 1, 'active')
    expect(updateResult.success).toBe(false)
    expect(updateResult.error).toBe(100)
  })
})
