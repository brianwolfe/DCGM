/*
 * Copyright (c) 2026, NVIDIA CORPORATION.  All rights reserved.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#include <catch2/catch_all.hpp>

#include <DcgmHostEngineHandler.h>
#include <DcgmProtocol.h>
#ifdef INJECTION_LIBRARY_AVAILABLE
#include <UnitTestHelpers.h>
#include <nvml_injection.h>
#endif
#include <DcgmRequest.h>

#include <algorithm>
#include <cstddef>
#include <dcgm_core_structs.h>
#include <dcgm_structs.h>
#include <dcgm_structs_internal.h>
#include <diag/dcgm_diag_structs.h>
#include <health/dcgm_health_structs.h>
#include <nvsdm/nvsdm.h>
#include <nvswitch/dcgm_nvswitch_structs.h>
#include <optional>
#include <sysmon/dcgm_sysmon_structs.h>
#include <unordered_set>
#include <vector>

#include <climits>
#include <vector>

/* Minimal concrete DcgmRequest subclass for testing AddRequestWatcher */
class TestRequest : public DcgmRequest
{
public:
    TestRequest()
        : DcgmRequest(DCGM_REQUEST_ID_NONE)
    {}
    int ProcessMessage(std::unique_ptr<DcgmMessage> /*msg*/) override
    {
        return DCGM_ST_OK;
    }
};

/* DcgmRequest subclass that captures every message delivered to it */
class CapturingRequest : public DcgmRequest
{
public:
    CapturingRequest()
        : DcgmRequest(DCGM_REQUEST_ID_NONE)
    {}
    std::vector<std::unique_ptr<DcgmMessage>> received;
    int ProcessMessage(std::unique_ptr<DcgmMessage> msg) override
    {
        received.push_back(std::move(msg));
        return DCGM_ST_OK;
    }
};

TEST_CASE("DcgmHostEngineHandler", "[HostEngineHandler]")
{
    SECTION("IsCoreModuleSubcommandDenied")
    {
        // Given the nature of the function, it's all but impossible to test it
        // without copying implementation details into the test
        static std::array<unsigned int, 2> constexpr DENY_LIST = { DCGM_CORE_SR_ATTACH_GPUS, DCGM_CORE_SR_DETACH_GPUS };
        // Check that denied subcommands are denied, others are not
        dcgm_module_command_header_t cmd {
            sizeof(dcgm_module_command_header_t), DcgmModuleIdCore, DCGM_CORE_SR_ATTACH_GPUS, 0, 0, 1
        };
        for (auto subCommand : DENY_LIST)
        {
            cmd.moduleId   = DcgmModuleIdCore;
            cmd.subCommand = subCommand;
            CHECK(DcgmHostEngineHandler::IsCoreModuleSubcommandDenied(&cmd));
            cmd.moduleId = DcgmModuleIdNvSwitch;
            CHECK(!DcgmHostEngineHandler::IsCoreModuleSubcommandDenied(&cmd));
        }
        cmd.moduleId   = DcgmModuleIdCore;
        cmd.subCommand = DCGM_CORE_SR_NVML_CREATE_FAKE_ENTITY;
        CHECK(!DcgmHostEngineHandler::IsCoreModuleSubcommandDenied(&cmd));
    }
}
