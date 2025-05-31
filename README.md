## Usage
    With fetchWithBase:

     Fetcher.fetchWithBase<T>(
      fetcher: useCases.call(...),
      state: state.<targetState>,
      emitter: (newData) => emit(state.copyWith(<targetState>: newData)),
      onStatusChange: (status) => print(status),
      );