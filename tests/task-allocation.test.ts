import { describe, it, expect, beforeEach } from 'vitest'

// Mock blockchain state
let tasks: { [key: number]: any } = {}
let lastTaskId = 0

// Mock contract functions
const createTask = (sender: string, missionId: number, droneId: number, taskType: string, priority: number, startTime: number, endTime: number) => {
  if (sender !== 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM') {
    return { success: false, error: 100 }
  }
  lastTaskId++
  tasks[lastTaskId] = {
    mission_id: missionId,
    drone_id: droneId,
    task_type: taskType,
    status: 'pending',
    priority,
    start_time: startTime,
    end_time: endTime
  }
  return { success: true, value: lastTaskId }
}

const updateTaskStatus = (sender: string, taskId: number, newStatus: string) => {
  if (sender !== 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM') {
    return { success: false, error: 100 }
  }
  if (!tasks[taskId]) {
    return { success: false, error: 101 }
  }
  if (!['in-progress', 'completed', 'failed'].includes(newStatus)) {
    return { success: false, error: 102 }
  }
  tasks[taskId].status = newStatus
  return { success: true }
}

const getMissionTasks = (missionId: number) => {
  return Object.entries(tasks)
      .filter(([_, task]) => task.mission_id === missionId)
      .map(([id, task]) => ({ ...task, task_id: parseInt(id) }))
}

const getDroneTasks = (droneId: number) => {
  return Object.entries(tasks)
      .filter(([_, task]) => task.drone_id === droneId)
      .map(([id, task]) => ({ ...task, task_id: parseInt(id) }))
}

describe('TaskAllocation', () => {
  beforeEach(() => {
    tasks = {}
    lastTaskId = 0
  })
  
  it('ensures tasks can be created, updated, and retrieved', () => {
    const deployer = 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM'
    
    const createResult = createTask(
        deployer,
        1,
        1,
        'surveillance',
        1,
        100,
        200
    )
    expect(createResult.success).toBe(true)
    expect(createResult.value).toBe(1)
    expect(tasks[1].task_type).toBe('surveillance')
    expect(tasks[1].status).toBe('pending')
    
    const updateResult = updateTaskStatus(deployer, 1, 'in-progress')
    expect(updateResult.success).toBe(true)
    expect(tasks[1].status).toBe('in-progress')
    
    const missionTasks = getMissionTasks(1)
    expect(missionTasks.length).toBe(1)
    
    const droneTasks = getDroneTasks(1)
    expect(droneTasks.length).toBe(1)
  })
  
  it('ensures only the contract owner can create and update tasks', () => {
    const deployer = 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM'
    const user1 = 'ST2CY5V39NHDPWSXMW9QDT3HC3GD6Q6XX4CFRK9AG'
    
    const createResult = createTask(
        user1,
        1,
        1,
        'unauthorized',
        1,
        100,
        200
    )
    expect(createResult.success).toBe(false)
    expect(createResult.error).toBe(100)
    
    const validCreateResult = createTask(
        deployer,
        1,
        1,
        'authorized',
        1,
        100,
        200
    )
    expect(validCreateResult.success).toBe(true)
    
    const updateResult = updateTaskStatus(user1, 1, 'in-progress')
    expect(updateResult.success).toBe(false)
    expect(updateResult.error).toBe(100)
  })
})

