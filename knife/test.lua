local test, testAssert, testError

-- Create a node representing a test section
local function createNode (parent, description, process)
    return setmetatable({
        parent = parent,
        description = description,
        process = process,
        nodes = {},
        activeNodeIndex = 1,
        currentNodeIndex = 0,
        assert = testAssert,
        error = testError,
    }, { __call = test })
end

-- Run a node
local function runNode (node)
    node.currentNodeIndex = 0
    return node:process()
end

-- Get the root node for a given node
local function getRootNode (node)
    local parent = node.parent
    return parent and getRootNode(parent) or node
end

-- Update the active child node of the given node
local function updateActiveNode (node, description, process)
    local activeNodeIndex = node.activeNodeIndex
    local nodes = node.nodes
    local activeNode = nodes[activeNodeIndex]

    if not activeNode then
        activeNode = createNode(node, description, process)
        nodes[activeNodeIndex] = activeNode
    else
        activeNode.process = process
    end

    getRootNode(node).lastActiveLeaf = activeNode

    return activeNode
end

-- Run the active child node of the given node
local function runActiveNode (node, description, process)
    local activeNode = updateActiveNode(node, description, process)
    return runNode(activeNode)
end

-- Get ancestors of a node, including the node
local function getAncestors (node)
    local ancestors = { node }
    for ancestor in function () return node.parent end do
        ancestors[#ancestors + 1] = ancestor
        node = ancestor
    end
    return ancestors
end

-- Print a message describing one execution path in the test scenario
local function printScenario (node)
    local ancestors = getAncestors(node)
    for i = #ancestors, 1, -1 do
        io.stderr:write(ancestors[i].description or '')
        io.stderr:write('\n')
    end
end

-- Print a message and stop the test scenario when an assertion fails
local function failAssert (node, description, message)
    io.stderr:write(message or '')
    io.stderr:write('\n\n')
    printScenario(node)
    io.stderr:write(description or '')
    io.stderr:write('\n\n')
    error(message or '', 2)
end

-- Create a branch node for a test scenario
test = function (node, description, process)
    node.currentNodeIndex = node.currentNodeIndex + 1
    if node.currentNodeIndex == node.activeNodeIndex then
        return runActiveNode(node, description, process)
    end
end

-- Test an assertion
testAssert = function (self, value, description)
    if not value then
        return failAssert(self, description, 'Test failed: assertion failed')
    end
    return value
end

-- Expect function f to fail
testError = function (self, f, description)
    if pcall(f) then
        return failAssert(self, description, 'Test failed: expected error')
    end
end

-- Create the root node for a test scenario
local function T (description, process)
    local root = createNode(nil, description, process)

    runNode(root)
    while root.activeNodeIndex <= #root.nodes do
        local lastActiveBranch = root.lastActiveLeaf.parent
        lastActiveBranch.activeNodeIndex = lastActiveBranch.activeNodeIndex + 1
        runNode(root)
    end

    return root
end

-- Run any other files passed from CLI.
if arg and arg[0] and arg[0]:gmatch('test.lua') then
    _G.T = T
    for i = 1, #arg do
        dofile(arg[i])
    end
    _G.T = nil
end

return T
