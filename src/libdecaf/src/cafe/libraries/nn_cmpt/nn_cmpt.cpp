#include "nn_cmpt.h"

namespace cafe::nn_cmpt
{

static int32_t
rpl_entry(coreinit::OSDynLoad_ModuleHandle moduleHandle,
          coreinit::OSDynLoad_EntryReason reason)
{
   return 0;
}

void
Library::registerSymbols()
{
   RegisterEntryPoint(rpl_entry);

   registerLibSymbols();
}

} // namespace cafe::nn_cmpt
