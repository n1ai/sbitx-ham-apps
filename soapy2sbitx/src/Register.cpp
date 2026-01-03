#include <SoapySDR/Registry.hpp>
#include "SBITXDevice.hpp"

static SoapySDR::KwargsList findSBITX(const SoapySDR::Kwargs &)
{
    SoapySDR::KwargsList results;
    SoapySDR::Kwargs dev;

    // This is displayed by  SoapySDRUtil --find
    dev["device"]       = "sBITX";
    dev["version"]      = "1.0";
    dev["part_id"]      = "SBITX-ALSA-IQ";
    dev["serial"]       = "SBITX-007";
    dev["label"]        = "sBitx (ALSA IQ bridge)";
    results.push_back(dev);
    return results;
}

static SoapySDR::Device *makeSBITX(const SoapySDR::Kwargs &args)
{
    return new SBITXDevice(args);
}

static SoapySDR::Registry registerSBITX("sbitx", &findSBITX, &makeSBITX, SOAPY_SDR_ABI_VERSION);
