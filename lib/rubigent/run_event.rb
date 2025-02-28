# frozen_string_literal: true

module Rubigent
  # Events that can be sent by the run() functions
  module RunEvent
    RUN_STARTED = "RunStarted"
    RUN_RESPONSE = "RunResponse"
    RUN_COMPLETED = "RunCompleted"
    RUN_ERROR = "RunError"
    TOOL_CALL_STARTED = "ToolCallStarted"
    TOOL_CALL_COMPLETED = "ToolCallCompleted"
    REASONING_STARTED = "ReasoningStarted"
    REASONING_STEP = "ReasoningStep"
    REASONING_COMPLETED = "ReasoningCompleted"
    UPDATING_MEMORY = "UpdatingMemory"
    WORKFLOW_STARTED = "WorkflowStarted"
    WORKFLOW_COMPLETED = "WorkflowCompleted"
  end
end
