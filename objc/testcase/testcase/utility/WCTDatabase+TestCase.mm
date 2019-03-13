/*
 * Tencent is pleased to support the open source community by making
 * WCDB available.
 *
 * Copyright (C) 2017 THL A29 Limited, a Tencent company.
 * All rights reserved.
 *
 * Licensed under the BSD 3-Clause License (the "License"); you may not use
 * this file except in compliance with the License. You may obtain a copy of
 * the License at
 *
 *       https://opensource.org/licenses/BSD-3-Clause
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#import <WCDB/Console.hpp>
#import <WCDB/SQLite.h>
#import <WCDB/WCTDatabase+TestCase.h>

static ssize_t illPwrite(int, const void *, size_t, off_t)
{
    return -1;
}

static ssize_t illPread(int, void *, size_t, off_t)
{
    return -1;
}

@implementation WCTDatabase (TestCase)

+ (void)resetGlobalErrorTracer
{
    WCDB::Console::shared()->setLogger(WCDB::Console::logger);
}

+ (void)simulateIOError:(BOOL)enable
{
    sqlite3_vfs *vfs = sqlite3_vfs_find(nullptr);
    sqlite3_mutex *mutex = sqlite3_mutex_alloc(SQLITE_MUTEX_STATIC_MASTER);
    sqlite3_mutex_enter(mutex);
    sqlite3_syscall_ptr newPwrite;
    sqlite3_syscall_ptr newPread;
    if (enable) {
        newPwrite = (sqlite3_syscall_ptr) illPwrite;
        newPread = (sqlite3_syscall_ptr) illPread;
    } else {
        newPwrite = (sqlite3_syscall_ptr) pwrite;
        newPread = (sqlite3_syscall_ptr) pread;
    }
    vfs->xSetSystemCall(vfs, "pwrite", (sqlite3_syscall_ptr) newPwrite);
    vfs->xSetSystemCall(vfs, "pread", (sqlite3_syscall_ptr) newPread);
    sqlite3_mutex_leave(mutex);
}

@end
