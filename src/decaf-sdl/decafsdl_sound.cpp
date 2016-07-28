#include "clilog.h"
#include "common/decaf_assert.h"
#include "decafsdl.h"
#include <SDL.h>

bool
DecafSDLSound::start(int outputRate, int numChannels)
{
   mNumChannelsIn = numChannels;
   mNumChannelsOut = std::min(numChannels, 2);  // TODO: support surround output
   mOutputFrameLen = 1024;  // TODO: make this configurable (latency control)

   // Set up the ring buffer with enough space for 3 output frames of audio
   mOutputBuffer.resize(mOutputFrameLen * mNumChannelsOut * 3);
   mBufferWritePos = 0;
   mBufferReadPos = 0;

   SDL_AudioSpec audiospec;
   audiospec.format = AUDIO_S16LSB;
   audiospec.freq = outputRate;
   audiospec.channels = mNumChannelsOut;
   audiospec.samples = mOutputFrameLen;
   audiospec.callback = sdlCallback;
   audiospec.userdata = this;

   if (SDL_OpenAudio(&audiospec, nullptr) != 0) {
      gCliLog->error("Failed to open audio device: {}", SDL_GetError());
      return false;
   }

   SDL_PauseAudio(0);
   return true;
}

void
DecafSDLSound::output(int16_t *samples, int numSamples)
{
   // Discard channels from the input if necessary.
   if (mNumChannelsIn != mNumChannelsOut) {
      decaf_check(mNumChannelsOut < mNumChannelsIn);
      for (int sample = 1; sample < numSamples; ++sample) {
         for (int channel = 0; channel < mNumChannelsOut; channel++) {
            samples[sample * mNumChannelsOut + channel] = samples[sample * mNumChannelsIn + channel];
         }
      }
   }

   // Copy to the output buffer, ignoring the possibility of overrun
   //  (which should never happen anyway).
   int numSamplesOut = numSamples * mNumChannelsOut;
   while (mBufferWritePos + numSamplesOut >= mOutputBuffer.size()) {
      size_t samplesToCopy = mOutputBuffer.size() - mBufferWritePos;
      memcpy(&mOutputBuffer[mBufferWritePos], samples, samplesToCopy * 2);
      mBufferWritePos = 0;
      samples += samplesToCopy;
      numSamplesOut -= samplesToCopy;
   }
   memcpy(&mOutputBuffer[mBufferWritePos], samples, numSamplesOut * 2);
   mBufferWritePos += numSamplesOut;
}

void
DecafSDLSound::stop()
{
   SDL_CloseAudio();
}

void
DecafSDLSound::sdlCallback(void *instance_, Uint8 *stream_, int size)
{
   DecafSDLSound *instance = reinterpret_cast<DecafSDLSound *>(instance_);
   int16_t *stream = reinterpret_cast<int16_t *>(stream_);
   decaf_check(size >= 0);
   decaf_check(size % (2 * instance->mNumChannelsOut) == 0);
   size_t numSamples = static_cast<size_t>(size) / 2;

   int samplesAvail = (instance->mBufferWritePos + instance->mOutputBuffer.size() - instance->mBufferReadPos) % instance->mOutputBuffer.size();
   if (samplesAvail < numSamples) {
      // Rather than outputting the partial frame, output a full frame of
      //  silence to give audio generation a chance to catch up.
      memset(stream, 0, size);
   } else {
      decaf_check(instance->mBufferReadPos + numSamples <= instance->mOutputBuffer.size());
      memcpy(stream, &instance->mOutputBuffer[instance->mBufferReadPos], size);
      instance->mBufferReadPos = (instance->mBufferReadPos + numSamples) % instance->mOutputBuffer.size();
   }
}